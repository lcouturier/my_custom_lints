// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/utils.dart';
import 'package:yaml/yaml.dart';

class AvoidBannedUsageRule extends BaseLintRule<AvoidBannedUsageParameters> {
  AvoidBannedUsageRule._(super.rule);

  factory AvoidBannedUsageRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'avoid_banned_usage',
      paramsParser: AvoidBannedUsageParameters.fromJson,
      problemMessage: (value) => '{0}',
    );

    return AvoidBannedUsageRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final forbiddenClasses = config.parameters.entries
        .expand((e) => (e.types.map((m) => (className: m, message: e.message, severity: e.severity))))
        .toList();

    context.registry.addInstanceCreationExpression((node) {
      // final filePath = resolver.source.fullName;
      final (found, result) =
          (forbiddenClasses.firstWhereOrNot((e) => e.className == node.constructorName.type.name2.lexeme));
      if (!found) return;

      reporter.reportErrorForNode(
        code,
        node.constructorName,
        [result?.message ?? node.constructorName.type.name2.lexeme],
      );
    });
  }
}

class AvoidBannedUsageParameters {
  final List<Entry> entries;

  factory AvoidBannedUsageParameters.fromJson(Map<String, Object?> map) {
    final yamlEntries = map['entries'] as YamlList;

    final entries = yamlEntries.map((e) {
      return Entry(
        paths: List<String>.from(e['paths'] as YamlList),
        types: List<String>.from(e['types'] as YamlList),
        message: e['message'] as String,
        severity: e['severity'] as String?,
      );
    }).toList();
    return AvoidBannedUsageParameters._(entries);
  }

  AvoidBannedUsageParameters._(this.entries);
}

class Entry {
  final List<String> paths;
  final List<String> types;
  final String message;
  final String? severity;

  Entry({required this.paths, required this.types, required this.message, this.severity});

  @override
  String toString() => 'Entry(paths: $paths, types: $types, message: $message, severity: $severity)';
}
