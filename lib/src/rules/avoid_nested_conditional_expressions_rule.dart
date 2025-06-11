// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
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
      problemMessage:
          (value) =>
              'Nested conditional expression is too complex. Try to reduce at ${value.maxNestingLevel} the number of nested conditional expressions.',
    );

    return AvoidNestedConditionalExpressionsRule._(rule);
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addConditionalExpression((node) {
      if ((node.thenExpression is! ConditionalExpression) && (node.elseExpression is! ConditionalExpression)) return;

      int count = node.depth;
      if (count <= config.parameters.maxNestingLevel) return;

      reporter.atNode(node, code);
    });
  }
}

extension on ConditionalExpression {
  int get depth {
    int count = 1;
    var current = this;
    while (current.thenExpression is ConditionalExpression || current.elseExpression is ConditionalExpression) {
      current =
          current.thenExpression is ConditionalExpression
              ? current.thenExpression as ConditionalExpression
              : current.elseExpression as ConditionalExpression;
      count++;
    }
    return count;
  }
}

class AvoidNestedConditionalExpressionParameters {
  final int maxNestingLevel;

  factory AvoidNestedConditionalExpressionParameters.fromJson(Map<String, Object?> map) {
    return AvoidNestedConditionalExpressionParameters(maxNestingLevel: map['max-nesting-level'] as int? ?? 2);
  }

  AvoidNestedConditionalExpressionParameters({required this.maxNestingLevel});
}
