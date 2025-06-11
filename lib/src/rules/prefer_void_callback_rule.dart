import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class PreferVoidCallbackRule extends BaseLintRule<PreferVoidCallbackParameters> {
  static const lintName = 'prefer_void_callback';

  PreferVoidCallbackRule._(super.rule);

  factory PreferVoidCallbackRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferVoidCallbackParameters.fromJson,
      problemMessage: (value) => 'Consider using VoidCallback instead of void Function().',
    );

    return PreferVoidCallbackRule._(rule);
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addVoidCallback((node) {
      reporter.atNode(node, code);
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithVoidCallBackFix()];
}

class _ReplaceWithVoidCallBackFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addVoidCallback((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final replacement = node.question == null ? 'VoidCallback' : 'VoidCallback?';
      final changeBuilder = reporter.createChangeBuilder(message: 'Replace with $replacement', priority: 80);

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.sourceRange, replacement);
      });
    });
  }
}

class PreferVoidCallbackParameters {
  const PreferVoidCallbackParameters();

  // ignore: avoid_unused_constructor_parameters
  factory PreferVoidCallbackParameters.fromJson(Map<String, Object?> json) {
    return const PreferVoidCallbackParameters();
  }
}
