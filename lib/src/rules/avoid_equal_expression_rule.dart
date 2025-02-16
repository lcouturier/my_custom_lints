// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidEqualExpressionsRule extends DartLintRule {
  static const lintName = 'avoid_equal_expressions';

  const AvoidEqualExpressionsRule()
      : super(
          code: const LintCode(
            name: 'avoid_equal_expressions',
            problemMessage: 'Avoid equal expressions.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context
      ..registry.addIfStatement((node) => _hasToReportError(node, reporter))
      ..registry.addVariableDeclaration((node) => _hasToReportError(node, reporter));
  }

  void _hasToReportError(AstNode node, ErrorReporter reporter) {
    final binary = switch (node) {
      IfStatement() when node.expression is BinaryExpression => node.expression as BinaryExpression,
      VariableDeclaration() when node.initializer is BinaryExpression => node.initializer! as BinaryExpression,
      _ => null,
    };

    if (binary != null) {
      if (binary.leftOperand.toString() == binary.rightOperand.toString()) {
        reporter.reportErrorForNode(code, node);
      }
    }
  }
}
