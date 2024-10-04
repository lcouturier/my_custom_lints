// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

class NumberOfParametersRule extends BaseLintRule<NumberOfParametersParameters> {
  static const lintName = 'number_of_parameters';

  NumberOfParametersRule._(super.rule);

  factory NumberOfParametersRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: NumberOfParametersParameters.fromJson,
      problemMessage: (value) => 'The maximum allowed number of parameters is ${value.maxParameters}. '
          'Try reducing the number of parameters.',
    );

    return NumberOfParametersRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      if (!config.enabled) return;
      if (node.metadata.any((e) => e.name.name.startsWith('Deprecated'))) return;

      if (node is! MethodDeclaration && node is! FunctionDeclaration) return;

      if (node is MethodDeclaration) {
        if ((node.parameters != null) && (node.parameters!.parameters.every((e) => e.isOptionalNamed))) return;
      }

      final parameters = switch (node) {
        (final MethodDeclaration node) => node.parameters?.parameters.length ?? 0,
        (final FunctionDeclaration node) => node.functionExpression.parameters?.parameters.length ?? 0,
        _ => 0,
      };

      if (parameters > config.parameters.maxParameters) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class NumberOfParametersParameters {
  final int maxParameters;

  const NumberOfParametersParameters({required this.maxParameters});

  factory NumberOfParametersParameters.fromJson(Map<String, Object?> map) {
    return NumberOfParametersParameters(
      maxParameters: map['max_parameters'] as int? ?? 7,
    );
  }
}
