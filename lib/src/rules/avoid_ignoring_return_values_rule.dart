// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.staticType is VoidType) return;
      if (node.staticType?.isDartAsyncFuture ?? false) return;

      if (node.parent is! ExpressionStatement) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addPropertyAccess((node) {
      if (node.staticType is VoidType) return;
      if (node.parent is! ExpressionStatement) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
