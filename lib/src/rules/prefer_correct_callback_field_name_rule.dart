// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class PreferCorrectCallbackFieldNBameRule extends BaseLintRule<PreferCorrectCallbackFieldNameParameters> {
  PreferCorrectCallbackFieldNBameRule._(super.rule);

  factory PreferCorrectCallbackFieldNBameRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'prefer_correct_callback_field_name',
      paramsParser: PreferCorrectCallbackFieldNameParameters.fromJson,
      problemMessage: (value) => '{0}',
    );

    return PreferCorrectCallbackFieldNBameRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclarationWidget((node) {
      for (final parameter in (node.declaredElement?.constructors ?? <ConstructorElement>[])
          .expand((e) => e.parameters.where((e) => e.type.isCallbackType))) {
        if (!RegExp(config.parameters.namePattern).hasMatch(parameter.name)) {
          final message =
              'This ${parameter.name} type does not match the configured pattern: ${config.parameters.namePattern}. Try renaming it.';

          reporter.atElement(
            parameter,
            code,
            arguments: [message],
          );
        }
      }
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
