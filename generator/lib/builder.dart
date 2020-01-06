library xson_builder.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

Builder retrofitCommandBuilder(BuilderOptions options) => LibraryBuilder(RetrofitCommGenerator(), generatedExtension: ".comm.dart");
