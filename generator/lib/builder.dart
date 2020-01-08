library command_runnable_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

Builder runnableBuilder(BuilderOptions options) => LibraryBuilder(RetrofitCommGenerator(), generatedExtension: ".comm.dart");
