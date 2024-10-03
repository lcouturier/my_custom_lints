// ignore_for_file: unused_element

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEqualThenElseRule extends DartLintRule {
  static const String lintName = 'no_equal_then_else';

  const NoEqualThenElseRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Then and else branches are equal.',
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
      if (node.elseStatement != null &&
          node.elseStatement is! IfStatement &&
          node.thenStatement.toString() == node.elseStatement.toString()) {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addConditionalExpression((node) {
      if (node.elseExpression is! IfStatement && node.thenExpression.toString() == node.elseExpression.toString()) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
