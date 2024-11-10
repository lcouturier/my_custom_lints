// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

class AvoidNestedSwitchExpressionRule extends BaseLintRule<AvoidNestedConditionalExpressionParameters> {
  AvoidNestedSwitchExpressionRule._(super.rule);

  factory AvoidNestedSwitchExpressionRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'avoid_nested_switch_expressions',
      paramsParser: AvoidNestedConditionalExpressionParameters.fromJson,
      problemMessage: (value) =>
          'Nested conditional expression is too complex. Try to reduce at ${value.maxNestingLevel} the number of nested conditional expressions.',
    );

    return AvoidNestedSwitchExpressionRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSwitchExpression((node) {
      for (var element in node.cases.whereType<SwitchExpression>()) {}

      int count = _getNumberOfNestedConditionalExpressions(node);
      log(count.toString());
      // if (count <= config.parameters.maxNestingLevel) return;
      // if (count <= 2) return;
      reporter.reportErrorForNode(code, node);
    });
  }

  int _getNumberOfNestedConditionalExpressions(SwitchExpression switchExpression) {
    int count = 1;
    for (var element in switchExpression.cases.whereType<SwitchExpression>()) {
      count += _getNumberOfNestedConditionalExpressions(element);
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
