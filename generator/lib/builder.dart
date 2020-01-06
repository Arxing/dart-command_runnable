library xson_builder.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder retrofitCommandBuilder(BuilderOptions options) => LibraryBuilder(XsonBeanGenerator(), generatedExtension: ".comm.dart");
