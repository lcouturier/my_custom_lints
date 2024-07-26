import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferIterableAnyRule extends BaseLintRule<PreferIterableAnyParameters> {
  static const lintName = 'prefer_iterable_any';

  PreferIterableAnyRule._(super.rule);

  factory PreferIterableAnyRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferIterableAnyParameters.fromJson,
      problemMessage: (value) =>
          'Using Iterable.where(...).isNotEmpty is more verbose than Iterable.any. Consider using Iterable.any for better readability.',
    );

    return PreferIterableAnyRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
      final propertyName = node.propertyName.name;
      if (propertyName != 'isNotEmpty') return;

      final propertyAccessTarget = node.realTarget;
      if (propertyAccessTarget is! MethodInvocation) return;

      final methodName = propertyAccessTarget.methodName.name;
      if (methodName != 'where') return;

      final target = propertyAccessTarget.realTarget;
      final targetType = target?.staticType;
      if (targetType == null) return;

      if (!iterableChecker.isAssignableFromType(targetType)) return;

      reporter.reportErrorForNode(
        code,
        node,
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterableAny()];
}

class _ReplaceWithIterableAny extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPropertyAccess((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final target = node.realTarget;
      if (target is! MethodInvocation) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with Iterable.any',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(target.methodName.sourceRange, 'any');
        // ignore: cascade_invocations
        builder.addDeletion(range.startEnd(node.operator, node.propertyName));
      });
    });
  }
}

class PreferIterableAnyParameters {
  const PreferIterableAnyParameters();

  // ignore: avoid_unused_constructor_parameters
  factory PreferIterableAnyParameters.fromJson(Map<String, Object?> map) {
    return const PreferIterableAnyParameters();
  }
}
