// Leave my library alone!
// ignore: unnecessary_library_directive
library;

import 'package:build/build.dart';
import 'package:rpc_generator/src/generator.dart';

/// Builds generators for `build_runner` to run.
// Needs to be top-level.
// ignore: prefer-static-class
Builder rpcBuilder(BuilderOptions options) => generatorFactoryBuilder(options);
