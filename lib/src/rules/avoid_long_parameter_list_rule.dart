// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';
import 'package:yaml/yaml.dart';

class AvoidLongParameterListRule extends BaseLintRule<AvoidLongParameterListParameters> {
  static const lintName = 'avoid_long_parameter_list';

  AvoidLongParameterListRule._(super.rule);

  factory AvoidLongParameterListRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidLongParameterListParameters.fromJson,
      problemMessage:
          (value) =>
              'The maximum allowed number of parameters is ${value.maxParameters}. '
              'Try reducing the number of parameters.',
    );

    return AvoidLongParameterListRule._(rule);
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclarationWithParameters((node) {
      if (config.parameters.ignoredNames.isNotEmpty && config.parameters.ignoredNames.contains(node.name.lexeme)) {
        return;
      }

      final count =
          config.parameters.ignoreOptional
              ? node.parameters!.parameters.countBy((e) => !e.isOptional)
              : node.parameters!.parameters.length;
      if (count > config.parameters.maxParameters) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidLongParameterListParameters {
  final int maxParameters;
  final bool ignoreOptional;
  final List<String> ignoredNames;

  factory AvoidLongParameterListParameters.fromJson(Map<String, Object?> map) {
    return AvoidLongParameterListParameters(
      maxParameters: map['max-parameters'] as int? ?? 7,
      ignoreOptional: map['ignore-optional'] as bool? ?? true,
      ignoredNames: List<String>.from((map['ignored-names'] ?? []) as YamlList),
    );
  }

  AvoidLongParameterListParameters({
    required this.maxParameters,
    required this.ignoreOptional,
    required this.ignoredNames,
  });
}
