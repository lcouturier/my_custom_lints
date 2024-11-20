// ignore_for_file: unused_import, inference_failure_on_collection_literal

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
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
    context.registry.addMethodInvocation((node) {
      final entry = config.parameters.entries.firstWhereOrNull((e) => e.name == node.methodName.name);
      if (entry == null) return;

      final checker = TypeChecker.fromName(entry.type);
      if (!checker.isAssignableFromType(node.realTarget!.staticType!)) return;

      reporter.reportErrorForNode(
        code.copyWith(
          errorSeverity: entry.severity == null
              ? ErrorSeverity.WARNING
              : ErrorSeverity.values.firstWhere(
                  (e) => e.name == entry.severity!.toUpperCase(),
                  orElse: () => ErrorSeverity.WARNING,
                ),
        ),
        node,
        [entry.message],
      );
    });
  }
}

class AvoidBannedUsageParameters {
  final List<FlattenEntry> entries;

  factory AvoidBannedUsageParameters.fromJson(Map<String, Object?> map) {
    final yamlEntries = (map['entries'] ?? []) as YamlList;

    final entries = yamlEntries.map((e) {
      return EntryType(
        type: e['type'] as String,
        entries: ((e['entries'] ?? []) as YamlList).map((e) {
          return Entry(
            names: List<String>.from(e['names'] as YamlList),
            message: e['description'] as String,
            severity: e['severity'] as String?,
          );
        }).toList(),
      );
    }).expand(
      (e) => e.entries.map((item) {
        return (type: e.type, names: item.names, message: item.message, severity: item.severity);
      }),
    );
    final result = entries
        .expand((e) =>
            e.names.map((name) => FlattenEntry(type: e.type, name: name, message: e.message, severity: e.severity)))
        .toList();

    return AvoidBannedUsageParameters._(result);
  }

  AvoidBannedUsageParameters._(this.entries);
}

class EntryType {
  final String type;
  final List<Entry> entries;

  EntryType({required this.type, required this.entries}); // <String, Entry>
}

class Entry {
  final List<String> names;
  final String message;
  final String? severity;

  Entry({required this.names, required this.message, required this.severity});

  @override
  String toString() => 'Entry(name: $names, message: $message, severity: $severity)';
}

class FlattenEntry {
  final String type;
  final String name;
  final String message;
  final String? severity;

  FlattenEntry({required this.type, required this.name, required this.message, required this.severity});

  @override
  String toString() => 'FlattenEntry(type: $type, name: $name, message: $message, severity: $severity)';
}
