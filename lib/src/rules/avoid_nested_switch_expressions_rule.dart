import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidNestedSwitchExpressionRule extends DartLintRule {
  const AvoidNestedSwitchExpressionRule()
      : super(
          code: const LintCode(
            name: 'avoid_nested_switch_expressions',
            problemMessage: 'Nested conditional expression is too complex.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSwitchExpression((node) {
      final (found, expr) = node.cases.firstWhereOrNot((e) => e.expression is SwitchExpression);
      if (!found) return;

      reporter.reportErrorForNode(code, expr!.expression as SwitchExpression);
    });
  }
}
