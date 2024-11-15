import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

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
    context.registry.addBinaryExpression((node) {
      if (node.leftOperand is PropertyAccess) {
        if ((node.operator.type != TokenType.EQ_EQ) && (node.operator.type != TokenType.BANG_EQ)) return;
        if (node.rightOperand is! BooleanLiteral) return;

        final leftOperand = node.leftOperand as PropertyAccess;
        if (leftOperand.staticType != null && !leftOperand.staticType.isNullable) return;

        final condition = node.toSource();
        final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;

        final message =
            'Use ${isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)'} instead of $condition.';

        reporter.reportErrorForNode(
          code,
          node,
          [message],
        );
      }

      if (node.leftOperand is SimpleIdentifier) {
        if ((node.operator.type != TokenType.EQ_EQ) && (node.operator.type != TokenType.BANG_EQ)) return;
        if (node.rightOperand is! BooleanLiteral) return;

        final leftOperand = node.leftOperand as SimpleIdentifier;
        if (leftOperand.staticType != null && !leftOperand.staticType.isNullable) return;

        final condition = node.toSource();
        final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;
        final message =
            'Use ${isCheckingTrue ? '$leftOperand ?? false' : '!($leftOperand ?? false)'} instead of $condition.';

        reporter.reportErrorForNode(
          code,
          node,
          [message],
        );
      }
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
    context.registry.addBinaryExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add null aware notation',
        priority: 80,
      );

      final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;

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
