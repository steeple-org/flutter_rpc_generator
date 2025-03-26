import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

@immutable
@Target({TargetKind.classType})
class RpcApi {
  final String path;
  final Type? callAdapter;

  const RpcApi(this.path, {this.callAdapter});
}

@immutable
@Target({TargetKind.field})
class RpcRouter {
  final String name;

  const RpcRouter(this.name);
}

@immutable
abstract class RpcMethod {
  final String name;
  final String httpMethod;
  final String paramAnnotation;

  const RpcMethod(this.name, this.httpMethod, this.paramAnnotation);
}

@immutable
@Target({TargetKind.method})
class RpcMutation extends RpcMethod {
  const RpcMutation(String name) : super(name, 'POST', 'Body()');
}

@immutable
@Target({TargetKind.method})
class RpcQuery extends RpcMethod {
  const RpcQuery(String name) : super(name, 'GET', "Query('input')");
}

@immutable
@Target({TargetKind.parameter})
class RpcInput {
  const RpcInput();
}
