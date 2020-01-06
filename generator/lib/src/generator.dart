import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:retrofit_commandable_annotation/retrofit_commandable.dart';

class RetrofitCommGenerator extends GeneratorForAnnotation<RetrofitCommandable> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element.kind != ElementKind.CLASS) return null;



    return null;
  }
}
