import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:yaml/yaml.dart';

class AvoidNullableBooleanRule extends BaseLintRule<AvoidNullableBooleanParameters> {
  AvoidNullableBooleanRule._(super.rule);

  factory AvoidNullableBooleanRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: 'avoid_nullable_boolean',
      paramsParser: AvoidNullableBooleanParameters.fromJson,
      problemMessage: (value) => 'Avoid usage of nullable boolean.',
    );

    return AvoidNullableBooleanRule._(rule);
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addNamedType((node) {
      if (node.type == null) return;
      if (!node.type!.isNullable) return;
      if (!node.type!.isDartCoreBool) return;
      if (_hasToIgnore(node)) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  bool _hasToIgnore(NamedType node) {
    if (node.parent is! SimpleFormalParameter) return false;
    final p = node.parent! as SimpleFormalParameter;
    final method = p.thisOrAncestorOfType<MethodDeclaration>();
    if (method == null) return false;

    final name = method.name.lexeme;
    return (config.parameters.ignoredNames.contains(name));
  }
}

class AvoidNullableBooleanParameters {
  final List<String> ignoredNames;

  factory AvoidNullableBooleanParameters.fromJson(Map<String, Object?> map) {
    return AvoidNullableBooleanParameters(
      ignoredNames: List<String>.from((map['ignored-names'] ?? []) as YamlList),
    );
  }

  AvoidNullableBooleanParameters({
    required this.ignoredNames,
  });
}
