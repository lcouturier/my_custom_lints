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
    context.registry.addRecordLiteral((node) {
      if (!config.enabled) return;

      if (node.fields.length > config.parameters.maxNumber) {
        reporter.reportErrorForNode(code, node);
      }
      if (node.fields.length < config.parameters.minNumber) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class AvoidLongRecordsParameters {
  final int minNumber;
  final int maxNumber;

  factory AvoidLongRecordsParameters.fromJson(Map<String, Object?> map) {
    return AvoidLongRecordsParameters(
      minNumber: map['min-number'] as int? ?? 2,
      maxNumber: map['max-number'] as int? ?? 5,
    );
  }

  AvoidLongRecordsParameters({required this.minNumber, required this.maxNumber});

  @override
  String toString() => '$minNumber <= number <= $maxNumber';
}
