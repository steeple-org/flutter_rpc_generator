// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'with_call_adapter.dart';

// **************************************************************************
// RpcGenerator
// **************************************************************************

class _MyRpcApi implements MyRpcApi {
  _MyRpcApi(Dio dio, String baseUrl)
    : fooRouter = _MyFooRpcRouter(dio, baseUrl: baseUrl),
      barRouter = _MyBarRpcRouter(dio, baseUrl: baseUrl);

  @override
  final MyFooRpcRouter fooRouter;

  @override
  final MyBarRpcRouter barRouter;
}

@RestApi(callAdapter: MyCallAdapter)
abstract class _MyFooRpcRouter implements MyFooRpcRouter {
  factory _MyFooRpcRouter(Dio dio, {String baseUrl}) = __MyFooRpcRouter;

  @override
  @GET('/path/trpc/foo.queryProcedure')
  Future<String> myFooQuery(@Query('input') String fooQueryParam);
  @override
  @POST('/path/trpc/foo.mutationProcedure')
  Future<void> myFooMutation(@Body() int fooMutationParam);
}

@RestApi(callAdapter: MyCallAdapter)
abstract class _MyBarRpcRouter implements MyBarRpcRouter {
  factory _MyBarRpcRouter(Dio dio, {String baseUrl}) = __MyBarRpcRouter;

  @override
  @GET('/path/trpc/bar.queryProcedure')
  Future<List<int>> myBarQuery();
}
