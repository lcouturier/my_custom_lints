import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidUnnecessaryNullAssertionRule extends DartLintRule {
  const AvoidUnnecessaryNullAssertionRule()
      : super(
            code: const LintCode(
          name: 'avoid_unnecessary_null_assertion',
          problemMessage: 'Avoid unnecessary null assertions.',
        ));

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIfStatementNullAssertion((condition, node, statements) {
      if (statements.any((e) => e.toSource().contains('${node.name}!'))) {
        reporter.reportErrorForNode(code, condition);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidUnnecessaryNullAssertionFix()];
}

class _AvoidUnnecessaryNullAssertionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIfStatementNullAssertion((condition, node, statements) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'If...case notation',
        priority: 80,
      );

      final variable = switch (node) { PrefixedIdentifier() => node, _ => node as SimpleIdentifier };

      changeBuilder.addDartFileEdit((builder) {
        if (variable is PrefixedIdentifier) {
          builder.addSimpleReplacement(
              range.node(condition), '${variable.name} case final ${variable.identifier.name}?');
        } else {
          builder.addSimpleReplacement(range.node(condition), '${variable.name} case final ${variable.name}?');
        }
        for (final expression in statements.where((e) => e.toSource().contains('${variable.name}!'))) {
          if (variable is PrefixedIdentifier) {
            builder.addSimpleReplacement(range.node(expression),
                expression.toSource().replaceAll('${variable.name}!', variable.identifier.name));
          } else {
            builder.addSimpleReplacement(
                range.node(expression), expression.toSource().replaceAll('${variable.name}!', variable.name));
          }
        }
      });
    });
  }
}
