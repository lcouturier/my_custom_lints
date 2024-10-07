// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

class AvoidLongRecordsRule extends BaseLintRule<AvoidLongRecordsParameters> {
  static const lintName = 'avoid_long_records';

  AvoidLongRecordsRule._(super.rule);

  factory AvoidLongRecordsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidLongRecordsParameters.fromJson,
      problemMessage: (value) =>
          'Records with high number of fields are difficult to reuse and maintain because they are usually responsible for more than one thing. Consider creating a class or splitting the record instead.',
    );

    return AvoidLongRecordsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addRecordLiteral((RecordLiteral node) {
      if (!config.enabled) return;

      if (node.fields.length > config.parameters.maxNumber) {
        reporter.reportErrorForNode(code, node);
      }
      if (!config.parameters.ignoreOneField && node.fields.length == 1) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class AvoidLongRecordsParameters {
  final int maxNumber;
  final bool ignoreOneField;

  factory AvoidLongRecordsParameters.fromJson(Map<String, Object?> map) {
    return AvoidLongRecordsParameters(
      maxNumber: map['max-number'] as int? ?? 5,
      ignoreOneField: map['ignore-one-field'] as bool? ?? false,
    );
  }

  AvoidLongRecordsParameters({required this.maxNumber, required this.ignoreOneField});

  @override
  String toString() => '$maxNumber';
}
