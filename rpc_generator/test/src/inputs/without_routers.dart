import 'package:rpc_annotations/rpc_annotations.dart';

part 'without_routers.g.dart';

@RpcApi('/path/trpc')
abstract class MyRpcApi {
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
