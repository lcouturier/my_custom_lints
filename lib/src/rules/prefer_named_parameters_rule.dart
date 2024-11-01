// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferNamedParametersRule extends BaseLintRule<PreferNamedParameters> {
  PreferNamedParametersRule._(super.rule);

  factory PreferNamedParametersRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'prefer_named_parameters',
      paramsParser: PreferNamedParameters.fromJson,
      problemMessage: (value) =>
          "With positional parameters, it's relatively easy to pass the wrong argument to a parameter (especially after a certain number of declared parameters). This rule helps avoid such mistakes.",
    );

    return PreferNamedParametersRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // context.registry.addConstructorDeclaration((node) {
    //   final parameters = node.parameters.parameters;
    //   if (parameters.countBy((e) => e.isPositional) == config.parameters.maxNumber) return;
    //   if (parameters.every((e) => e.isNamed)) return;

    //   reporter.reportErrorForNode(code, node);
    // });

    context.registry.addMethodDeclaration((node) {
      final parameters = node.parameters?.parameters ?? <FormalParameter>[];
      final map = parameters.groupBy((e) => e.declaredElement?.type);
      if (map.length != 1) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}

class PreferNamedParameters {
  final int maxNumber;

  factory PreferNamedParameters.fromJson(Map<String, Object?> map) {
    final maxNumber = map['max-number'] as int? ?? 1;

    return PreferNamedParameters(maxNumber: maxNumber);
  }

  PreferNamedParameters({
    required this.maxNumber,
  });
}
