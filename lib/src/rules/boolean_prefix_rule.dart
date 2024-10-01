// ignore_for_file: lines_longer_than_80_chars

// ignore: unused_import
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class BooleanPrefixesRule extends BaseLintRule<BooleanPrefixParameters> {
  static const lintName = 'boolean_prefixes';

  BooleanPrefixesRule._(super.rule);

  factory BooleanPrefixesRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: BooleanPrefixParameters.fromJson,
      problemMessage: (value) => 'Invalid prefix. Try using one of these: $value.',
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
      if (config.parameters.ignoreFields) return;

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

    context.registry.addGetterDeclaration((node) {
      if (config.parameters.ignoreGetters) return;

      if (node.returnType?.type == null || !(node.returnType?.type!.isDartCoreBool ?? false)) return;
      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForNode(
        code,
        node,
        [
          'Boolean getter',
          'getter',
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

    context.registry.addFormalParameter((node) {
      if (config.parameters.ignoreParameters) return;

      final returnType = node.declaredElement?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      final name = node.name?.lexeme ?? '';
      if (isNameValid(name)) return;

      reporter.reportErrorForNode(
        code,
        node,
        ['Method that returns a boolean', 'method'],
      );
    });

    context.registry.addMethodDeclaration((node) {
      if (!config.parameters.ignoreMethods) return;

      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;
      if (node.isOperator) return;

      final element = node.declaredElement;
      if (element == null || element.hasOverride) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        node.name,
        ['Method that returns a boolean', 'method'],
      );
    });

    context.registry.addFunctionDeclaration((node) {
      if (config.parameters.ignoreMethods) return;

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
    if (name.isEmpty) return true;
    if (name.containsOnlyUnderscores) return true;

    final nameWithoutUnderscore = name.startsWith('_') ? name.substring(1) : name;

    if (config.parameters.ignoredNames.any((e) => e == nameWithoutUnderscore)) return true;

    final validPrefixes = config.parameters.prefixes;
    return validPrefixes.any(nameWithoutUnderscore.startsWith);
  }
}

class BooleanPrefixParameters {
  final bool ignoreMethods;
  final bool ignoreFields;
  final bool ignoreParameters;
  final bool ignoreGetters;
  final List<String> ignoredNames;
  final List<String> prefixes;

  static final List<String> _defaultPrefixes = ['is', 'has', 'should'];

  factory BooleanPrefixParameters.fromJson(Map<String, Object?> map) {
    final prefixes = map['prefixes'] as String? ?? '';
    final ignoredNames = map['ignored-names'] as String? ?? '';

    return BooleanPrefixParameters(
      ignoreMethods: map['ignore-methods'] as bool? ?? false,
      ignoreFields: map['ignore-fields'] as bool? ?? false,
      ignoreParameters: map['ignore-parameters'] as bool? ?? false,
      ignoreGetters: map['ignore-getters'] as bool? ?? false,
      ignoredNames: ignoredNames.isEmpty ? [] : ignoredNames.removeAllSpaces().split(',').map((e) => e.trim()).toList(),
      prefixes:
          prefixes.isEmpty ? _defaultPrefixes : prefixes.removeAllSpaces().split(',').map((e) => e.trim()).toList(),
    );
  }

  BooleanPrefixParameters({
    required this.ignoreMethods,
    required this.ignoreFields,
    required this.ignoreParameters,
    required this.ignoredNames,
    required this.ignoreGetters,
    required this.prefixes,
  });

  @override
  String toString() {
    return prefixes.join(', ');
  }
}
