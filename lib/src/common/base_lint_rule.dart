// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

typedef RuleProblemFactory<T> = String Function(T value);
typedef RuleParameterParser<T> = T Function(Map<String, Object?> json);

class RuleConfig<T extends Object?> {
  RuleConfig({
    required this.name,
    required CustomLintConfigs configs,
    required RuleProblemFactory<T> problemMessage,
    RuleParameterParser<T>? paramsParser,
  })  : enabled = configs.rules[name]?.enabled ?? false,
        parameters = paramsParser?.call(configs.rules[name]?.json ?? {}) as T,
        _problemMessageFactory = problemMessage;

  final String name;

  final bool enabled;

  final T parameters;

  final RuleProblemFactory<T> _problemMessageFactory;

  LintCode get lintCode => LintCode(
        name: name,
        errorSeverity: ErrorSeverity.WARNING,
        problemMessage: _problemMessageFactory(parameters),
      );
}

abstract class BaseLintRule<T extends Object?> extends DartLintRule {
  BaseLintRule(this.config) : super(code: config.lintCode);

  final RuleConfig<T> config;

  bool get enabled => config.enabled;
}
