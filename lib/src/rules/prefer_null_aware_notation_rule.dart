import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class PreferNullAwareNotationRule extends DartLintRule {
  const PreferNullAwareNotationRule()
      : super(
          code: const LintCode(
            name: 'prefer_null_aware_notation',
            problemMessage: 'Use null-aware operator (??) for null checks.',
            correctionMessage: '{0}',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNullAwareExpression((node, isCheckingTrue) {
      final condition = node.toSource();
      final leftOperand = node.leftOperand;
      final message =
          'Use ${isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)'} instead of $condition.';

      reporter.reportErrorForNode(
        code,
        node,
        [message],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_PreferNullAwareNotationFix()];
}

class _PreferNullAwareNotationFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addNullAwareExpression((node, isCheckingTrue) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add null aware notation',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        const replacement = '?? false';
        if (isCheckingTrue) {
          builder.addSimpleReplacement(
            range.startEnd(node.operator, node.rightOperand),
            replacement,
          );
        } else {
          builder.addSimpleReplacement(
            range.node(node),
            '!(${node.leftOperand} $replacement)',
          );
        }
      });
    });
  }
}
