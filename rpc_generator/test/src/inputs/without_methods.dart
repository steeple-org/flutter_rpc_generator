import 'package:rpc_annotations/rpc_annotations.dart';

part 'without_methods.g.dart';

@RpcApi('/path/trpc')
abstract class MyRpcApi {
  @RpcRouter('foo')
  abstract final MyFooRpcRouter fooRouter;

  @RpcRouter('bar')
  abstract final MyBarRpcRouter barRouter;

  factory MyRpcApi(Dio dio, String baseUrl) = _MyRpcApi;
}

abstract class MyFooRpcRouter {}

abstract class MyBarRpcRouter {}
