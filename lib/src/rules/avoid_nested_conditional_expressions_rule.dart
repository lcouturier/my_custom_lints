// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

class AvoidNestedConditionalExpressionsRule extends BaseLintRule<AvoidNestedConditionalExpressionParameters> {
  AvoidNestedConditionalExpressionsRule._(super.rule);

  factory AvoidNestedConditionalExpressionsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'avoid_nested_conditional_expressions',
      paramsParser: AvoidNestedConditionalExpressionParameters.fromJson,
      problemMessage: (value) =>
          'Nested conditional expression is too complex. Try to reduce at ${value.maxNestingLevel} the number of nested conditional expressions.',
    );

    return AvoidNestedConditionalExpressionsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addConditionalExpression((node) {
      if ((node.thenExpression is! ConditionalExpression) && (node.elseExpression is! ConditionalExpression)) return;

      int count = _getNumberOfNestedConditionalExpressions(node);
      if (count <= config.parameters.maxNestingLevel) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  int _getNumberOfNestedConditionalExpressions(ConditionalExpression expression) {
    int count = 1;
    if (expression.thenExpression is ConditionalExpression) {
      count += _getNumberOfNestedConditionalExpressions(expression.thenExpression as ConditionalExpression);
    }
    if (expression.elseExpression is ConditionalExpression) {
      count += _getNumberOfNestedConditionalExpressions(expression.elseExpression as ConditionalExpression);
    }
    return count;
  }
}

class AvoidNestedConditionalExpressionParameters {
  final int maxNestingLevel;

  factory AvoidNestedConditionalExpressionParameters.fromJson(Map<String, Object?> map) {
    return AvoidNestedConditionalExpressionParameters(
      maxNestingLevel: map['max-nesting-level'] as int? ?? 2,
    );
  }

  AvoidNestedConditionalExpressionParameters({required this.maxNestingLevel});
}
