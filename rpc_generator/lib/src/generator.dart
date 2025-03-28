// ignore_for_file: avoid-long-functions, prefer-extracting-function-callbacks, avoid-mutating-parameters
// For reference : https://dinkomarinac.dev/from-annotations-to-generation-building-your-first-dart-code-generator

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:rpc_annotations/rpc_annotations.dart';
import 'package:source_gen/source_gen.dart';

// This method has to be top-level.
// ignore: prefer-static-class
Builder generatorFactoryBuilder(BuilderOptions options) {
  return PartBuilder(
    [const RpcGenerator()],
    '.rpc.dart',
    header: '''
    // coverage:ignore-file
    // GENERATED CODE - DO NOT MODIFY BY HAND
        ''',
    options: options,
  );
}

TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

class RpcGenerator extends Generator {
  const RpcGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Get all availables classes.
    final libraryClasses = library.classes;

    // Get `RpcApi` and `RpcRouter` annotations types.
    final rpcApiAnnotation = _typeChecker(RpcApi);
    final rpcRouterAnnotation = _typeChecker(RpcRouter);

    // For every available class, put it in `annotatedClasses` if it is
    // annotated with `RpcApi`, along with its `ConstantReader`. The
    // `ConstantReader` value is useful for reading the annotation fields.
    final annotatedClasses = Map<ClassElement, ConstantReader>.fromEntries(
      libraryClasses.map((libraryClass) {
        final annotation = rpcApiAnnotation.firstAnnotationOfExact(
          libraryClass,
        );

        return annotation != null
            ? MapEntry(libraryClass, ConstantReader(annotation))
            : null;
      }).nonNulls,
    );

    // Used to store the generated classes.
    final classes = <String>[];

    // For every annotated class, generate its associated Rpc api class and
    // extract its annoted `RpcRouter` fields to generate the associated Rpc
    // Routers.
    for (final annotatedClass in annotatedClasses.entries) {
      // Get the class element.
      final clss = annotatedClass.key;

      // Extract `RpcApi` annotation fields.
      final apiPath = annotatedClass.value.read('path').stringValue;
      final callAdapter = annotatedClass.value.peek('callAdapter')?.typeValue;

      // Generate the associated rpc class and store it in generated classes
      // list.
      classes.add(_generateRpcApiClass(clss));

      // For every class field, put it in `annotatedFields` if it is  annotated
      // with `RpcRouter`, along with its `ConstantReader`. The `ConstantReader`
      // value is useful for reading the annotation fields.
      final annotatedFields = Map<FieldElement, ConstantReader>.fromEntries(
        clss.fields.map((field) {
          final annotation = rpcRouterAnnotation.firstAnnotationOfExact(field);

          return annotation != null
              ? MapEntry(field, ConstantReader(annotation))
              : null;
        }).nonNulls,
      );

      // For every annotated field with `RpcRouter`, find its associated class
      // and generate the associated Rpc router class.
      for (final rpcRouterAnnotatedFieldEntry in annotatedFields.entries) {
        // The field element.
        final field = rpcRouterAnnotatedFieldEntry.key;
        // Get the class associated with the field type. E.g., if the field is
        // of type `ExampleRouter`, we search this class in the available
        // classes, in order to generate the Router class.
        final associatedClass = libraryClasses.firstWhereOrNull((libraryClass) {
          return libraryClass.name == field.type.getDisplayString();
        });

        // If no associated class is found, we cannot generate the Router class
        // associated with the field.
        if (associatedClass == null) {
          // This is a warning.
          // ignore: avoid_print
          print(
            'Warning: no associated router class for field `${field.name}` in class ${clss.name}.',
          );
        } else {
          // Extract the router name from the `RpcRouter` annotation.
          final routerName =
              rpcRouterAnnotatedFieldEntry.value.read('name').stringValue;

          // Generate the associated Rpc router class and store it in generated
          // classes list.
          classes.add(
            _generateRpcRouterClass(
              apiPath,
              callAdapter,
              routerName,
              associatedClass,
            ),
          );
        }
      }
    }

    // Formats all the generated classes and return the result.
    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(classes.join('\n\n'));
  }

  // Generates a Rpc api class from a class element (annotated with `RpcApi`).
  String _generateRpcApiClass(ClassElement element) {
    final className = '_${element.name}';
    // Get `RpcRouter` annotation type.
    final rpcRouterAnnotation = _typeChecker(RpcRouter);
    // Get class fields annotated with `RpcRouter`.
    final annotatedFields = element.fields.where(
      rpcRouterAnnotation.hasAnnotationOf,
    );

    // Create the Api class.
    final apiClass = Class((clss) {
      clss
        ..name = className
        // Make the api class implements the class element.
        ..implements.add(refer(element.name))
        // Copy all annotated fields to the api class, and add the `@override`
        // annotation and the `final` modifier.
        ..fields.addAll(
          annotatedFields.map((annotatedField) {
            return Field((field) {
              field
                ..annotations.add(refer('override'))
                ..modifier = FieldModifier.final$
                ..type = refer(annotatedField.type.getDisplayString())
                ..name = annotatedField.name;
            });
          }),
        )
        // Create the api class constructor.
        ..constructors.add(
          Constructor((cst) {
            cst
              // Add two required non-named parameters: `Dio dio` and
              // `String baseUrl`.
              ..requiredParameters.addAll(
                {'dio': 'Dio', 'baseUrl': 'String'}.entries.map((entry) {
                  return Parameter((param) {
                    param
                      ..type = refer(entry.value)
                      ..name = entry.key;
                  });
                }),
              )
              // Initializes all the annotated fields.
              ..initializers.addAll(
                annotatedFields.map((annotatedField) {
                  return Code(
                    '${annotatedField.name} = _${annotatedField.type.getDisplayString()}(dio, baseUrl: baseUrl)',
                  );
                }),
              );
          }),
        );
    });

    final emitter = DartEmitter(useNullSafetySyntax: true);

    // Formats the generated api class and return the result.
    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format('${apiClass.accept(emitter)}');
  }

  // Generate a Rpc router class from a field and its associated class element.
  String _generateRpcRouterClass(
    String apiPath,
    DartType? callAdapter,
    String routerName,
    ClassElement associatedClass,
  ) {
    // Get `RpcMethod` annotation type.
    final rpcMethodAnnotation = _typeChecker(RpcMethod);

    // For every method in the class element, put it `annotatedMethods` if it
    // is annotated with a `RpcMethod` annotation (so either `RpcQuery` or
    // `RpcMutation`), along with its `ConstantReader`. The `ConstantReader`
    // value is useful for reading the annotation fields.
    final annotatedMethods = Map<MethodElement, ConstantReader>.fromEntries(
      associatedClass.methods.map((method) {
        final annotation = rpcMethodAnnotation.firstAnnotationOf(method);

        return annotation != null
            ? MapEntry(method, ConstantReader(annotation))
            : null;
      }).nonNulls,
    );

    final associatedClassName = associatedClass.name;
    // If a call adapter is provided, create an expression that will be added to
    // the `RestApi` retrofit annotation.
    final callAdapterExpression =
        callAdapter != null
            ? 'callAdapter: ${callAdapter.getDisplayString()}'
            : null;

    // Create the Router class.
    final routerClass = Class((clss) {
      clss
        // Add the `RestApi` annotation.
        ..annotations.add(refer('RestApi(${callAdapterExpression ?? ''})'))
        // Make the class abstract.
        ..abstract = true
        ..name = '_$associatedClassName'
        // Make the router class implements the associated class.
        ..implements.add(refer(associatedClassName))
        // Create the router class factory constructor.
        ..constructors.add(
          Constructor((constructor) {
            constructor
              ..factory = true
              // Add a required non-named parameter: `Dio dio`.
              ..requiredParameters.add(
                Parameter((param) {
                  param
                    ..type = refer('Dio')
                    ..name = 'dio';
                }),
              )
              // Add an optional named parameter: `String baseUrl`.
              ..optionalParameters.add(
                Parameter((param) {
                  param
                    ..type = refer('String')
                    ..name = 'baseUrl'
                    ..named = true;
                }),
              )
              // Redirects to the generated associated class.
              ..redirect = refer('__$associatedClassName');
          }),
        )
        // Generate all queries and mutations methods (i.e. annotated with
        // `RpcQuery` or `RpcMutation` and add them to the router class.
        ..methods.addAll(
          annotatedMethods.entries.map((entry) {
            return _generateMethod(entry.key, entry.value, apiPath, routerName);
          }),
        );
    });

    final emitter = DartEmitter(useNullSafetySyntax: true);

    // Formats the generated router class and return the result.
    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format('${routerClass.accept(emitter)}');
  }

  // Generate a Rpc method from a method element.
  Method _generateMethod(
    MethodElement method,
    ConstantReader annotation,
    String apiPath,
    String routerName,
  ) {
    // Extract `RpcMethod` annotation fields.
    final rpcMethodName = annotation.read('name').stringValue;
    final httpMethod = annotation.read('httpMethod').stringValue;
    final paramAnnotation = annotation.read('paramAnnotation').stringValue;

    // Get `RpcInput` annotation type.
    final rpcInputAnnotation = _typeChecker(RpcInput);
    // Get the first method parameter annotated with `RpcInput`.
    final annotatedParam = method.parameters.firstWhereOrNull(
      rpcInputAnnotation.hasAnnotationOfExact,
    );

    // Create the query or mutation method.
    return Method((m) {
      m
        // Add the `@override` annotation and the retrofit HTTP annotation
        // depending on the `RpcMethod` annotation type (e.g. `@GET` for
        // `RpcQuery` and `@POST` for `RpcMutation`).
        ..annotations.addAll([
          refer('override'),
          refer("$httpMethod('$apiPath/$routerName.$rpcMethodName')"),
        ])
        // Copy the method return type and its name.
        ..returns = refer(method.returnType.getDisplayString())
        ..name = method.name;

      if (annotatedParam != null) {
        // If an annotated param is present, add it to the method.
        m.requiredParameters.add(
          Parameter((param) {
            param
              // Add the retrofit parameter annotation depending on the
              // `RpcMethod` annotation type (e.g. `@Query('input')` for
              // `RpcQuery` and `@Body` for `RpcMutation`).
              ..annotations.add(refer(paramAnnotation))
              // Copy the parameter type and its name.
              ..type = refer(annotatedParam.type.getDisplayString())
              ..name = annotatedParam.name;
          }),
        );
      }
    });
  }
}
