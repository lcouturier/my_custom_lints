// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidEqualExpressionsRule extends DartLintRule {
  static const lintName = 'avoid_equal_expressions';

  const AvoidEqualExpressionsRule()
      : super(
          code: const LintCode(
            name: 'avoid_equal_expressions',
            problemMessage: 'Avoid equal expressions.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      if (node.expression is! BinaryExpression) return;

      final binary = node.expression as BinaryExpression;
      if (binary.leftOperand.toString() != binary.rightOperand.toString()) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addVariableDeclaration((node) {
      if (node.initializer is! BinaryExpression) return;

      final binary = node.initializer! as BinaryExpression;
      if (binary.leftOperand.toString() != binary.rightOperand.toString()) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
