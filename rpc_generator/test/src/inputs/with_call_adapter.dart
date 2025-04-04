import 'package:rpc_annotations/rpc_annotations.dart';

part 'with_call_adapter.g.dart';

class MyCallAdapter {
  const MyCallAdapter();
}

@RpcApi('/path/trpc', callAdapter: MyCallAdapter)
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
