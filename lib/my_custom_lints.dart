// ignore_for_file: unused_import

library my_custom_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/rules/avoid_bang_operator_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_print_rule.dart';
import 'package:my_custom_lints/src/rules/avoid_widget_function_rule.dart';
import 'package:my_custom_lints/src/rules/number_of_parameters_rule.dart';

import 'package:my_custom_lints/src/rules/prefer_returning_condition_rule.dart';

PluginBase createPlugin() => _MyCustomLint();

class _MyCustomLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return <LintRule>[
      const NumberOfParametersRule(),
      const AvoidPrintRule(),
      const AvoidBangOperatorRule(),
      const AvoidWidgetFunctionRule(),
      const PreferReturningConditionRule(),
    ];
  }

  @override
  List<Assist> getAssists() {
    return <Assist>[];
  }
}
