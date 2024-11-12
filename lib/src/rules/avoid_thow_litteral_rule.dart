import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidThrowLiteral extends DartLintRule {
  const AvoidThrowLiteral()
      : super(
          code: const LintCode(
            name: 'avoid_thow_literal',
            problemMessage: 'Throwing literal is an anti-pattern. Use throw Exception() instead.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addThrowExpression((node) {
      log(node.expression.runtimeType.toString());

      if (node.expression is! Literal) return;
      reporter.reportErrorForNode(code, node);
    });
  }
}
