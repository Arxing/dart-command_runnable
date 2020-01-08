import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:command_runnable/command_runnable.dart';
import 'package:dartpoet/dartpoet.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

Logger log = Logger('*****************');

class RetrofitCommGenerator extends GeneratorForAnnotation<CommandRunnable> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element.kind != ElementKind.CLASS) return null;

    Type commandActionType = CommandAction;
    Type commandOptionType = CommandOption;
    var runnerCode = annotation.peek('runnerCode')?.stringValue;
    var className = element.name;
    var file = FileSpec.build();
    file.dependencies.add(DependencySpec.import('package:args/command_runner.dart'));
    file.dependencies.add(DependencySpec.import('dart:async'));
    file.dependencies.addAll(element.library.imports.where((o) => o.uri != null).map((o) => DependencySpec.import(o.uri)).toList());
    var commandsCollectionClass = ClassSpec.build(
      '${className}Commands',
      constructorBuilder: (classSpec) sync* {
        yield ConstructorSpec.normal(
          classSpec,
          parameters: [
            ParameterSpec.normal(
              'runnerProvider',
              type: TypeToken.ofName('$className Function()'),
            )
          ],
          codeBlock: CodeBlockSpec.line('\n_runner = runnerProvider();'),
        );
      },
      properties: [
        PropertySpec.of('_runner', type: TypeToken.ofName(className)),
      ],
    );
    file.classes.add(commandsCollectionClass);

    ClassElement classElement = element as ClassElement;
    classElement.methods.forEach((methodElement) {
      var foundCommandActionAnnotation = methodElement.metadata.firstWhere(
        (elementAnnotation) => elementAnnotation.constantValue?.type?.name == commandActionType.toString(),
        orElse: () => null,
      );
      if (foundCommandActionAnnotation == null) return;
      var commandInstance = foundCommandActionAnnotation.constantValue;
      var methodName = methodElement.displayName;
      var commandName = commandInstance.getField('name').toStringValue() ?? methodName;
      var commandDescription = commandInstance.getField('description').toStringValue();
      var asynchronous = commandInstance.getField('asynchronous').toBoolValue();

//      var params = Map<String, String>.fromIterable(methodElement.parameters, key: (el) => el.name, value: (el) => el.type.name);
      var params = methodElement.parameters.map((paramElement) {
        var paramName = paramElement.name;
        var type = TypeToken.ofFullName(paramElement.type.displayName);
        var foundCommandOptionAnnotation = paramElement.metadata.firstWhere(
          (elementAnnotation) => elementAnnotation.constantValue.type.name == commandOptionType.toString(),
          orElse: () => null,
        );
        if (foundCommandOptionAnnotation != null) {
          var optionInstance = foundCommandOptionAnnotation.constantValue;
          var optionName = optionInstance.getField('optionName').toStringValue() ?? paramName;
          var help = optionInstance.getField('help').toStringValue();
          return _ParamInfo(name: paramName, optionName: optionName, help: help, type: type);
        } else {
          return _ParamInfo(name: paramName, optionName: paramName, type: type);
        }
      }).toList();

      TypeToken returnType = TypeToken.ofFullName(methodElement.returnType.displayName);
      TypeToken resultType;
      if (returnType.typeName == 'Future')
        resultType = returnType.firstGeneric;
      else
        resultType = returnType;
      var commandClass = ClassSpec.build(
        '_${commandName}Command',
        superClass: TypeToken.ofName('Command'),
        properties: [
          PropertySpec.of('_runner', type: TypeToken.ofName(className)),
          PropertySpec.ofString('name', defaultValue: '"$commandName"'),
          PropertySpec.ofString('description', defaultValue: commandDescription != null ? '"$commandDescription"' : '""'),
        ],
        constructorBuilder: (classSpec) sync* {
          var codes = CodeBlockSpec.line('this.argParser\n${params.map((paramInfo) {
            if (paramInfo.help != null)
              return "..addOption('${paramInfo.optionName}', help: '${paramInfo.help}')";
            else
              return "..addOption('${paramInfo.optionName}')";
          }).join()};');
          yield ConstructorSpec.normal(
            classSpec,
            parameters: [
              ParameterSpec.normal('_runner', isSelfParameter: true),
            ],
            codeBlock: codes,
          );
        },
        methods: [
          MethodSpec.build(
            'run',
            returnType: TypeToken.ofName('FutureOr', [resultType]),
            metas: [MetaSpec.ofInstance('override')],
            asynchronousMode: asynchronous ? AsynchronousMode.asyncFuture : AsynchronousMode.none,
            codeBlock: CodeBlockSpec.line('return _runner.\n${methodName}(${params.map((paramInfo) {
              return "${paramInfo.name}: argResults['${paramInfo.optionName}']";
            }).join(',\n')});'),
          )
        ],
      );
      file.classes.add(commandClass);
      commandsCollectionClass.getters.add(GetterSpec.build(
        commandName,
        type: TypeToken.ofName('Command'),
        codeBlock: CodeBlockSpec.line('${commandClass.className}(_runner);'),
      ));
    });

    var allCommandsGetter = GetterSpec.build(
      'allCommands',
      type: TypeToken.ofListByToken(TypeToken.ofName('Command')),
      codeBlock: CodeBlockSpec.line('[${commandsCollectionClass.getters.map((getter) => getter.getterName).join(', ')}];'),
    );
    commandsCollectionClass.getters.add(allCommandsGetter);

    DartFile dartFile = DartFile.fromFileSpec(file);
    return dartFile.outputContent();
  }
}

class _ParamInfo {
  String name;
  String optionName;
  TypeToken type;
  String help;

  _ParamInfo({
    this.name,
    this.optionName,
    this.type,
    this.help,
  });
}
