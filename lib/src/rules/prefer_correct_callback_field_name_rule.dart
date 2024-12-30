// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/error/listener.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferCorrectCallbackFieldNBameRule extends BaseLintRule<PreferCorrectCallbackFieldNameParameters> {
  PreferCorrectCallbackFieldNBameRule._(super.rule);

  factory PreferCorrectCallbackFieldNBameRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'prefer_carrect_callback_field_name',
      paramsParser: PreferCorrectCallbackFieldNameParameters.fromJson,
      problemMessage: (value) => "{0}",
    );

    return PreferCorrectCallbackFieldNBameRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFieldDeclaration((node) {
      if (node.fields.type == null) return;
      if (!node.fields.type!.type!.isCallbackType) return;

      final name = node.fields.variables.first.name.lexeme;
      final nameWithoutUnderscore = name.startsWith('_') ? name.substring(1) : name;
      if (RegExp(config.parameters.namePattern).hasMatch(nameWithoutUnderscore)) return;

      final message =
          "This $name type does not match the configured pattern: ${config.parameters.namePattern}. Try renaming it.";

      reporter.reportErrorForNode(
        code,
        node,
        [message],
      );
    });
  }
}

class PreferCorrectCallbackFieldNameParameters {
  final String namePattern;

  factory PreferCorrectCallbackFieldNameParameters.fromJson(Map<String, Object?> map) {
    final namePattern = map['name-pattern'] as String? ?? '^on[A-Z]+';
    return PreferCorrectCallbackFieldNameParameters(namePattern: namePattern);
  }

  PreferCorrectCallbackFieldNameParameters({required this.namePattern});
}
