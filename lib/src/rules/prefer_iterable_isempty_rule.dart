// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class PreferIterableIsEmptyRule extends BaseLintRule<PreferIterableIsAnyParameters> {
  static const lintName = 'prefer_iterable_isempty';

  PreferIterableIsEmptyRule._(super.rule);

  factory PreferIterableIsEmptyRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferIterableIsAnyParameters.fromJson,
      problemMessage: (value) => 'Prefer using `.isEmpty` over `.length == 0`.',
    );

    return PreferIterableIsEmptyRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBinaryExpression((node) {
      if ((node.leftOperand is! PropertyAccess) && (node.leftOperand is! PrefixedIdentifier)) return;
      if (node.rightOperand is! IntegerLiteral) return;

      final propertyName = switch (node.leftOperand) {
        PrefixedIdentifier prefixedIdentifier => prefixedIdentifier.identifier.name,
        PropertyAccess propertyAccess => propertyAccess.propertyName.name,
        _ => null,
      };

      if (propertyName != 'length') return;

      final targetType = switch (node.leftOperand) {
        PrefixedIdentifier prefixedIdentifier => prefixedIdentifier.prefix.staticType,
        PropertyAccess propertyAccess => propertyAccess.realTarget.staticType,
        StringLiteral stringLiteral => stringLiteral.staticType,
        _ => null,
      };

      if (targetType == null) return;
      if (!targetType.isDartCoreString && !targetType.isDartCoreIterable) return;

      if ((node.rightOperand as IntegerLiteral).value != 0) return;

      reporter.reportErrorForNode(
        code,
        node.parent!,
      );
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterablIsEmpty()];
}

class _ReplaceWithIterablIsEmpty extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addBinaryExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final value = (node.rightOperand as IntegerLiteral).value.toString();

      final useDirect = (node.operator.type == TokenType.EQ_EQ && value == '0') ||
          (node.operator.type == TokenType.BANG_EQ && value == '0');

      final changeBuilder = reporter.createChangeBuilder(
        message: useDirect ? 'Just use isEmpty' : 'Just use isNotEmpty',
        priority: 80,
      );

      final range = node.sourceRange;
      changeBuilder.addDartFileEdit((builder) {
        final replacement = node.leftOperand.toString().replaceFirst('.length', useDirect ? '.isEmpty' : '.isNotEmpty');
        builder.addSimpleReplacement(
          range,
          replacement,
        );
      });
    });
  }
}

class PreferIterableIsAnyParameters {
  const PreferIterableIsAnyParameters();

  // ignore: avoid_unused_constructor_parameters
  factory PreferIterableIsAnyParameters.fromJson(Map<String, Object?> map) {
    return const PreferIterableIsAnyParameters();
  }
}
