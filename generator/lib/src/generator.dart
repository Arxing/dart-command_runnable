import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:retrofit_commandable/comm.dart';
import 'package:source_gen/source_gen.dart';

class RetrofitCommGenerator extends GeneratorForAnnotation<RetrofitCommandable> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element.kind != ElementKind.CLASS) return null;

    ClassElement classElement = element as ClassElement;
    classElement.methods.where((methodElement) {
      methodElement.metadata.any((annotation) {
        var name = annotation.element.name;
        print('name=$name');
      });
    });

//    classElement.methods.where((m){
//      m.metadata.first.element.
//    })

    return null;
  }
}
