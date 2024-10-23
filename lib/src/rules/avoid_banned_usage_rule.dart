// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/error/error.dart';
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
        .expand((e) => (e.paths.map(
              (p) => (
                className: e.className,
                message: e.message,
                severity: e.severity,
                package: e.package,
                path: p,
              ),
            )))
        .toList();

    context.registry.addNamedType((node) {
      final (found, result) = (forbiddenClasses.firstWhereOrNot((e) => e.className == node.name2.lexeme));
      if (!found) return;

      if (result?.package != null && node.type != null) {
        final checker = TypeChecker.fromName(result!.className, packageName: '${result.package}');
        if (!checker.isAssignableFromType(node.type!)) return;
      }

      // final filePath = resolver.source.fullName;
      // if (forbiddenClasses.every((e) => !filePath.contains(e.path))) return;

      reporter.reportErrorForNode(
        code.copyWith(
          errorSeverity: result?.severity == null
              ? ErrorSeverity.WARNING
              : ErrorSeverity.values.firstWhere(
                  (e) => e.name == result!.severity!.toUpperCase(),
                  orElse: () => ErrorSeverity.WARNING,
                ),
        ),
        node,
        [result?.message ?? node.name2.lexeme],
      );
    });
  }
}

extension on LintCode {
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    ErrorSeverity? errorSeverity,
  }) {
    return LintCode(
      name: name ?? this.name,
      problemMessage: problemMessage ?? this.problemMessage,
      correctionMessage: correctionMessage ?? this.correctionMessage,
      uniqueName: uniqueName ?? this.uniqueName,
      url: url ?? this.url,
      errorSeverity: errorSeverity ?? this.errorSeverity,
    );
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
