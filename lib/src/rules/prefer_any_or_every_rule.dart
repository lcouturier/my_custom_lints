// ignore_for_file: unused_element, cascade_invocations, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferAnyOrEveryRule extends BaseLintRule<PreferAnyOrEveryParameters> {
  static const lintName = 'prefer_any_or_every';

  PreferAnyOrEveryRule._(super.rule);

  factory PreferAnyOrEveryRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferAnyOrEveryParameters.fromJson,
      problemMessage: (value) =>
          'Using .any() or .every() helps to abort the calculation when the condition is true (or false) the first time, resulting in more performant code.',
    );

    return PreferAnyOrEveryRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
      final propertyName = node.propertyName.name;
      if (propertyName == 'isNotEmpty') {
        final propertyAccessTarget = node.realTarget;
        if (propertyAccessTarget is MethodInvocation && propertyAccessTarget.methodName.name == 'where') {
          final target = propertyAccessTarget.realTarget;
          final targetType = target?.staticType;
          if (targetType == null) return;
          if (!iterableChecker.isAssignableFromType(targetType)) return;

          reporter.reportErrorForNode(
            code,
            node,
          );
        }
      }

      if (propertyName == 'isEmpty') {
        final propertyAccessTarget = node.realTarget;
        if (propertyAccessTarget is MethodInvocation && propertyAccessTarget.methodName.name == 'where') {
          final target = propertyAccessTarget.realTarget;
          final targetType = target?.staticType;
          if (targetType == null) return;
          if (!iterableChecker.isAssignableFromType(targetType)) return;

          reporter.reportErrorForNode(
            code,
            node,
          );
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_PreferAnyOrEveryFix()];
}

class _PreferAnyOrEveryFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPropertyAccess((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final propertyName = node.propertyName.name;
      if (propertyName == 'isNotEmpty') {
        final target = node.realTarget;
        if (target is! MethodInvocation) return;

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Replace with Iterable.any',
          priority: 80,
        );

        changeBuilder.addDartFileEdit((builder) {
          builder
            ..addSimpleReplacement(target.methodName.sourceRange, 'any')
            ..addDeletion(range.startEnd(node.operator, node.propertyName));
        });
      }
      if (propertyName == 'isEmpty') {
        final target = node.realTarget;
        if (target is! MethodInvocation) return;

        final arg = target.argumentList.arguments.singleOrNull;
        if (arg is! FunctionExpression) return;

        final argType = arg.staticType;
        if (argType is! FunctionType) return;
        if (!argType.returnType.isDartCoreBool) return;

        final expression = switch (arg.body) {
          BlockFunctionBody(:final block) => block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
          ExpressionFunctionBody(:final expression) => expression,
          _ => null,
        };

        if (expression == null) return;
        final type = expression.staticType;
        if (type == null || !type.isDartCoreBool) return;

        final changeBuilder = reporter.createChangeBuilder(message: 'Replace with Iterable.every', priority: 80);

        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(target.methodName.sourceRange, 'every');
          if (expression is PrefixExpression && expression.operator.type == TokenType.BANG) {
            builder.addDeletion(expression.operator.sourceRange);
          } else if (expression is IsExpression) {
            if (expression.notOperator != null) {
              builder.addDeletion(expression.notOperator!.sourceRange);
            } else {
              builder.addSimpleInsertion(expression.isOperator.end, TokenType.BANG.lexeme);
            }
          } else if (expression is BinaryExpression) {
            final (token, inverted) = expression.operator.type.invert;
            if (inverted) {
              builder.addSimpleReplacement(expression.operator.sourceRange, token.lexeme);
            }
          } else {
            builder.addSimpleInsertion(expression.sourceRange.offset, '!(');
            builder.addSimpleInsertion(expression.sourceRange.end, ')');
          }

          builder.addDeletion(range.startEnd(node.operator, node.propertyName));
        });
      }
    });
  }
}

class PreferAnyOrEveryParameters {
  const PreferAnyOrEveryParameters();

  // ignore: avoid_unused_constructor_parameters
  factory PreferAnyOrEveryParameters.fromJson(Map<String, Object?> map) {
    return const PreferAnyOrEveryParameters();
  }
}
