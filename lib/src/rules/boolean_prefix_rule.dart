// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

class BooleanPrefixesRule extends BaseLintRule<BooleanPrefixParameters> {
  static const lintName = 'boolean_prefixes';

  BooleanPrefixesRule._(super.rule);

  factory BooleanPrefixesRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: BooleanPrefixParameters.fromJson,
      problemMessage: (value) => 'Invalid prefix. Try using one of these: $value',
    );

    return BooleanPrefixesRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFieldDeclaration((node) {
      if (node.fields.type == null || !node.fields.type!.type!.isDartCoreBool) return;
      final name = node.fields.variables.first.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForNode(
        code,
        node,
        [
          'Boolean field',
          'field',
        ],
      );
    });
    context.registry.addBooleanLiteral((node) {
      final parent = node.parent;
      if (parent is! VariableDeclaration) return;

      final name = parent.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        parent.name,
        [
          'Boolean variable',
          'variable',
        ],
      );
    });

    context.registry.addMethodDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      if (node.isOperator) return;

      final element = node.declaredElement;
      if (element == null || element.hasOverride) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      final parameter = node.parameters;
      switch (parameter) {
        case null:
          reporter.reportErrorForToken(
            code,
            node.name,
            ['Getter that returns a boolean', 'getter'],
          );
        case _:
          reporter.reportErrorForToken(
            code,
            node.name,
            ['Method that returns a boolean', 'method'],
          );
      }
    });

    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        node.name,
        ['Function that returns a boolean', 'function'],
      );
    });
  }

  bool isNameValid(String name) {
    final nameWithoutUnderscore = name.startsWith('_') ? name.substring(1) : name;

    final validPrefixes = config.parameters.prefixes;
    return validPrefixes.any(nameWithoutUnderscore.startsWith);
  }
}

class BooleanPrefixParameters {
  final List<String> prefixes;

  static final List<String> _defaultPrefixes = ['is', 'has'];

  factory BooleanPrefixParameters.fromJson(Map<String, Object?> map) {
    final value = map['prefixes'] as String? ?? '';

    return BooleanPrefixParameters(
      prefixes: value.isEmpty ? _defaultPrefixes : value.split(',').map((e) => e.trim()).toList(),
    );
  }

  BooleanPrefixParameters({required this.prefixes});

  @override
  String toString() => prefixes.join(', ');
}
