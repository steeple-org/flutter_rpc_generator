// dart format width=80
// coverage:ignore-file
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

@RestApi()
abstract class _MyFooRpcRouter implements MyFooRpcRouter {
  factory _MyFooRpcRouter(Dio dio, {String baseUrl}) = __MyFooRpcRouter;

  @override
  @GET('/path/trpc/foo.queryProcedure')
  @UseCallAdapter(MyCallAdapter)
  Future<String> myFooQuery(@Query('input') String fooQueryParam);
  @override
  @POST('/path/trpc/foo.mutationProcedure')
  @UseCallAdapter(MyCallAdapter)
  Future<void> myFooMutation(@Body() int fooMutationParam);
}

@RestApi()
abstract class _MyBarRpcRouter implements MyBarRpcRouter {
  factory _MyBarRpcRouter(Dio dio, {String baseUrl}) = __MyBarRpcRouter;

  @override
  @GET('/path/trpc/bar.queryProcedure')
  @UseCallAdapter(MyCallAdapter)
  Future<List<int>> myBarQuery();
}
