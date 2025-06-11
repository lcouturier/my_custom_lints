import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidUselessSpreadRule extends DartLintRule {
  const AvoidUselessSpreadRule()
    : super(
        code: const LintCode(
          name: 'avoid_useless_spread',
          problemMessage: 'Useless spread operator.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addUselessSpreadOperator((node, elements) {
      reporter.atNode(node, code);
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
    context.registry.addUselessSpreadOperator((node, elements) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Remove spread operator', priority: 80);

      bool hasToDelete = elements.isEmpty && node.typeArguments != null;
      if (hasToDelete) {
        changeBuilder.addDartFileEdit((builder) {
          builder.addDeletion(
            range.startEnd(
              node.beginToken.previous!,
              (node.endToken.next?.type == TokenType.COMMA) ? node.endToken.next! : node.endToken,
            ),
          );
        });
      } else {
        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          builder
            ..addDeletion(range.token(node.beginToken.previous!))
            ..addDeletion(range.token(node.beginToken));
          if (node.endToken.previous?.type == TokenType.COMMA) {
            builder.addDeletion(range.token(node.endToken.previous!));
          }
          builder.addDeletion(range.token(node.endToken));
        });
      }
    });
  }
}
