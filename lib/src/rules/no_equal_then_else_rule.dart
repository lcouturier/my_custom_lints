// ignore_for_file: unused_element

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEqualThenElseRule extends DartLintRule {
  const NoEqualThenElseRule()
      : super(
          code: const LintCode(
            name: 'no_equal_then_else',
            problemMessage: 'Then and else branches are equal.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry
      ..addIfStatement((node) {
        bool hasToReport = (node.elseStatement != null &&
            node.elseStatement is! IfStatement &&
            node.thenStatement.toString() == node.elseStatement.toString());
        if (hasToReport) {
          reporter.reportErrorForNode(code, node);
        }
      })
      ..addConditionalExpression((node) {
        bool hasToReport =
            (node.elseExpression is! IfStatement && node.thenExpression.toString() == node.elseExpression.toString());
        if (hasToReport) {
          reporter.reportErrorForNode(code, node);
        }
      });
  }
}
