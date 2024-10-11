// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidSingleChildColumnOrRowRule extends BaseLintRule<AvoidSingleChildColumnOrRowParameters> {
  AvoidSingleChildColumnOrRowRule._(super.rule);

  factory AvoidSingleChildColumnOrRowRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'avoid_single_child_column_or_row',
      paramsParser: AvoidSingleChildColumnOrRowParameters.fromJson,
      problemMessage: (value) => 'Avoid single child Column or Row.',
    );

    return AvoidSingleChildColumnOrRowRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!config.parameters.widgets.contains(node.constructorName.type.name2.lexeme)) return;
      if (node.argumentList.arguments.isEmpty) return;

      final (found, p) = node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNot((e) => e.name.label.name == 'children');
      if (!found) return;

      if (p!.expression is! ListLiteral) return;
      if ((p.expression as ListLiteral).elements.length != 1) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }
}

class AvoidSingleChildColumnOrRowParameters {
  final List<String> widgets;

  factory AvoidSingleChildColumnOrRowParameters.fromJson(Map<String, Object?> map) {
    final items = map['widgets'] as String? ?? '';
    return AvoidSingleChildColumnOrRowParameters(
      widgets: items.isEmpty ? [] : items.removeAllSpaces().split(',').map((e) => e.trim()).toList(),
    );
  }

  AvoidSingleChildColumnOrRowParameters({required this.widgets});
}
