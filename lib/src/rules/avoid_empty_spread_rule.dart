import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidUselessSpreadRule extends DartLintRule {
  const AvoidUselessSpreadRule()
      : super(
          code: const LintCode(
            name: 'avoid_empty_spread',
            problemMessage: 'Avoid useless spread.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addListLiteral((node) {
      if (node.beginToken.previous?.type != TokenType.PERIOD_PERIOD_PERIOD) return;
      if (node.elements.length > 1) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidUselessSpreadFix()];
}

// ignore: unused_element
class _AvoidUselessSpreadFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addListLiteral((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;
      if (node.elements.isEmpty) return;
      if (node.typeArguments != null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove spread operator',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addDeletion(range.token(node.beginToken.previous!))
          ..addDeletion(range.token(node.beginToken));
        if (node.endToken.previous?.type == TokenType.COMMA) {
          builder.addDeletion(range.token(node.endToken.previous!));
        }
        builder
          .addDeletion(range.token(node.endToken));
      });
    });
  }
}
