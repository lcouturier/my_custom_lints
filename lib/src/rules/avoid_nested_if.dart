import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidNestedIfRule extends BaseLintRule<AvoidNestedIfOptions> {
  static const lintName = 'max_nesting_level';

  AvoidNestedIfRule._(super.rule);

  factory AvoidNestedIfRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidNestedIfOptions.fromJson,
      problemMessage: (value) => 'The maximum nesting level is ${value.numberOfLevel}. '
          'Try reducing the number of nested if .',
    );

    return AvoidNestedIfRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      final depth = node.depth((e) => e is IfStatement);

      if (depth > config.parameters.numberOfLevel) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class AvoidNestedIfOptions {
  final int numberOfLevel;

  const AvoidNestedIfOptions({required this.numberOfLevel});

  factory AvoidNestedIfOptions.fromJson(Map<String, Object?> map) {
    return AvoidNestedIfOptions(
      numberOfLevel: map['number_of_level'] as int? ?? 2,
    );
  }
}
