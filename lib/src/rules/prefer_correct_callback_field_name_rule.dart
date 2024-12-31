// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferCorrectCallbackFieldNBameRule extends BaseLintRule<PreferCorrectCallbackFieldNameParameters> {
  PreferCorrectCallbackFieldNBameRule._(super.rule);

  factory PreferCorrectCallbackFieldNBameRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'prefer_correct_callback_field_name',
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
    context.registry.addCallbackFieldDeclaration((node, fieldName) {
      if (RegExp(config.parameters.namePattern).hasMatch(fieldName)) return;

      final message =
          "This $fieldName type does not match the configured pattern: ${config.parameters.namePattern}. Try renaming it.";

      reporter.reportErrorForNode(
        code,
        node,
        [message],
      );
    });
  }

  @override
  List<Fix> getFixes() => [_PreferCorrectCallbackFieldNBameFix()];
}

class _PreferCorrectCallbackFieldNBameFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addCallbackFieldDeclaration((node, fieldName) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final newName = 'on${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Rename field to $newName',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        if (node.parent case final parent?) {
          builder
            ..addSimpleReplacement(range.node(parent), parent.toSource().replaceAll(fieldName, newName))
            ..format(range.node(parent));
        } else {
          builder
            ..addSimpleReplacement(range.node(node), node.toSource().replaceAll(fieldName, newName))
            ..format(range.node(node));
        }
      });
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

extension on LintRuleNodeRegistry {
  void addCallbackFieldDeclaration(void Function(FieldDeclaration node, String fieldName) listener) {
    addFieldDeclaration((node) {
      if (node.fields.type == null) return;
      if (!node.fields.type!.type!.isCallbackType) return;

      final name = node.fields.variables.first.name.lexeme;
      if (name.startsWith('_')) return;

      listener(node, name);
    });
  }
}
