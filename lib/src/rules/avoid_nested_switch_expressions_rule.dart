// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
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
