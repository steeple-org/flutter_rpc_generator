import 'package:generator_test/generator_test.dart';
import 'package:rpc_generator/src/generator.dart';
import 'package:test/test.dart';

void main() {
  SuccessGenerator createGenerator(String fileName) {
    return SuccessGenerator(
      ['$fileName.dart'],
      ['$fileName.g.dart'],
      const RpcGenerator(),
      partOfFile: '$fileName.dart',
      inputDir: 'test/src/inputs',
      fixtureDir: 'test/src/expected',
    );
  }

  test('RpcGenerator - classic file', () async {
    await createGenerator('classic_file').test();
  });

  test('RpcGenerator - without routers', () async {
    await createGenerator('without_routers').test();
  });

  test('RpcGenerator - without methods', () async {
    await createGenerator('without_methods').test();
  });

  test('RpcGenerator - with call adapter', () async {
    await createGenerator('with_call_adapter').test();
  });
}
