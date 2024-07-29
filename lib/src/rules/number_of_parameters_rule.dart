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
      final parameters = switch (node) {
        (final MethodDeclaration node) => node.parameters?.parameters.length ?? 0,
        (final FunctionDeclaration node) => node.functionExpression.parameters?.parameters.length ?? 0,
        _ => 0,
      };

      if (parameters > config.parameters.maxParameters) {
        reporter.reportErrorForOffset(
          code,
          node.firstTokenAfterCommentAndMetadata.offset,
          node.end,
        );
      }
    });
  }
}

class NumberOfParametersParameters {
  final int maxParameters;

  const NumberOfParametersParameters({required this.maxParameters});

  factory NumberOfParametersParameters.fromJson(Map<String, Object?> json) {
    return NumberOfParametersParameters(
      maxParameters: json['max_parameters'] as int? ?? 7,
    );
  }
}
