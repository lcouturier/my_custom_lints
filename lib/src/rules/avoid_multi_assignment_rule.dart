import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidMultiAssignmentRule extends DartLintRule {
  const AvoidMultiAssignmentRule()
      : super(
          code: const LintCode(
            name: 'avoid_multi_assignment',
            problemMessage:
                'Multiple assignments on the same line can lead to confusion or indicate an incorrect operator.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addAssignmentExpression((AssignmentExpression node) {
      if (node.rightHandSide is AssignmentExpression) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
