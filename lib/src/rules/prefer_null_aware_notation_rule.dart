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
            problemMessage: 'Prefer null-aware notation.',
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

        reporter.reportErrorForNode(code, node);
      }

      if (node.leftOperand is SimpleIdentifier) {
        if ((node.operator.type != TokenType.EQ_EQ) && (node.operator.type != TokenType.BANG_EQ)) return;
        if (node.rightOperand is! BooleanLiteral) return;

        final leftOperand = node.leftOperand as SimpleIdentifier;
        if (leftOperand.staticType != null && !leftOperand.staticType.isNullable) return;

        reporter.reportErrorForNode(code, node);
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

      changeBuilder.addDartFileEdit((builder) {
        const replacement = '?? false';
        builder.addSimpleReplacement(
          range.startEnd(node.operator, node.rightOperand),
          replacement,
        );
      });
    });
  }
}
