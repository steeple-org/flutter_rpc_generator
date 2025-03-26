// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'without_methods.dart';

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
}

@RestApi()
abstract class _MyBarRpcRouter implements MyBarRpcRouter {
  factory _MyBarRpcRouter(Dio dio, {String baseUrl}) = __MyBarRpcRouter;
}
