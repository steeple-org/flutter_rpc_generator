import 'package:rpc_annotations/rpc_annotations.dart';

part 'classic_file.g.dart';

@RpcApi('/path/trpc')
abstract class MyRpcApi {
  @RpcRouter('foo')
  abstract final MyFooRpcRouter fooRouter;

  @RpcRouter('bar')
  abstract final MyBarRpcRouter barRouter;

  factory MyRpcApi(Dio dio, String baseUrl) = _MyRpcApi;
}

abstract class MyFooRpcRouter {
  @RpcQuery('queryProcedure')
  Future<String> myFooQuery(@RpcInput() String fooQueryParam);

  @RpcMutation('mutationProcedure')
  Future<void> myFooMutation(@RpcInput() int fooMutationParam);
}

abstract class MyBarRpcRouter {
  @RpcQuery('queryProcedure')
  Future<List<int>> myBarQuery();
}
