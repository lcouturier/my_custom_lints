// ignore_for_file: unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidIgnoringReturnValuesRule extends DartLintRule {
  const AvoidIgnoringReturnValuesRule()
    : super(
        code: const LintCode(
          name: 'avoid_ignoring_return_values',
          problemMessage: 'return value is silently ignored.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addExpressionStatement((node) {
      if (node.expression is! InvocationExpression) return;
      if (!_hasUnusedResult(node.expression.staticType)) return;

      reporter.reportErrorForNode(code, node);
    });
    // context.registry.addMethodInvocation((node) {
    //   if (node.parent is! ExpressionStatement) return;
    //   if (!_hasUnusedResult(node.staticType)) return;

    //   reporter.reportErrorForNode(code, node);
    // });

    // context.registry.addPropertyAccess((node) {
    //   if (node.parent is! ExpressionStatement) return;
    //   if (!_hasUnusedResult(node.staticType)) return;

    //   reporter.reportErrorForNode(code, node);
    // });

    // context.registry.addPrefixedIdentifier((node) {
    //   if (node.parent is! ExpressionStatement) return;
    //   if (node.staticElement?.kind != ElementKind.GETTER) return;
    //   if (!_hasUnusedResult(node.staticType)) return;

    //   reporter.reportErrorForNode(code, node);
    // });

    // context.registry.addAwaitExpression((node) {
    //   if (node.parent is! ExpressionStatement) return;
    //   if (!_hasUnusedResult(node.staticType)) return;

    //   reporter.reportErrorForNode(code, node);
    // });
  }

  bool _hasUnusedResult(DartType? type) =>
      type != null && !_isEmptyType(type) && !_isEmptyFutureType(type) && !_isEmptyFutureOrType(type);

  bool _isEmptyType(DartType type) =>
      // ignore: deprecated_member_use
      type.isBottom || type.isDartCoreNull || type.isVoid;

  bool _isEmptyFutureType(DartType type) =>
      type is InterfaceType && type.isDartAsyncFuture && type.typeArguments.any(_isEmptyType);

  bool _isEmptyFutureOrType(DartType type) =>
      type is InterfaceType && type.isDartAsyncFutureOr && type.typeArguments.any(_isEmptyType);
}
