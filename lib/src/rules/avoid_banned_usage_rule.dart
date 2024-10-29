// ignore_for_file: unused_import

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
    context.registry.addNamedType((node) {
      final entry = config.parameters.entries.firstWhereOrNull((e) => e.className == node.name2.lexeme);
      if (entry == null) return;

      if (entry.package != null && node.type != null) {
        final checker = TypeChecker.fromName(entry.className, packageName: '${entry.package}');
        if (!checker.isAssignableFromType(node.type!)) return;
      }

      if (entry.paths.isNotEmpty) {
        final filePath = resolver.source.fullName;
        if (entry.paths.every((e) => !filePath.contains(e))) return;
      }

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
  final List<Entry> entries;

  factory AvoidBannedUsageParameters.fromJson(Map<String, Object?> map) {
    final yamlEntries = map['entries'] as YamlList;

    final entries = yamlEntries.map((e) {
      return Entry(
        paths: List<String>.from(e['paths'] as YamlList),
        className: e['class_name'] as String,
        package: e['package'] as String?,
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
  final String className;
  final String? package;
  final String message;
  final String? severity;

  Entry({required this.paths, required this.className, required this.message, required this.package, this.severity});

  @override
  String toString() =>
      'Entry(paths: $paths, types: $className, package: $package, message: $message, severity: $severity)';
}
