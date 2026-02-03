import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:rpc_generator/src/generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  Future<void> testGenerator(String fileName) async {
    final inputPath = 'test/src/inputs/$fileName.dart';
    final expectedPath = 'test/src/expected/$fileName.g.dart';

    final inputContent = File(inputPath).readAsStringSync();
    final expectedContent = File(expectedPath).readAsStringSync();

    final readerWriter = TestReaderWriter(rootPackage: 'a');
    await readerWriter.testing.loadIsolateSources();

    final builder = PartBuilder(
      [const RpcGenerator()],
      '.g.dart',
      header: '''
    // coverage:ignore-file
    // GENERATED CODE - DO NOT MODIFY BY HAND
      ''',
    );

    await testBuilder(
      builder,
      {
        'a|lib/$fileName.dart': inputContent,
      },
      outputs: {
        'a|lib/$fileName.g.dart': decodedMatches(expectedContent),
      },
      readerWriter: readerWriter,
    );
  }

  test('RpcGenerator - classic file', () async {
    await testGenerator('classic_file');
  });

  test('RpcGenerator - without routers', () async {
    await testGenerator('without_routers');
  });

  test('RpcGenerator - without methods', () async {
    await testGenerator('without_methods');
  });

  test('RpcGenerator - with call adapter', () async {
    await testGenerator('with_call_adapter');
  });
}
