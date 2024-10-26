// ignore_for_file: cascade_invocations, unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidUnsafeReduceRule extends DartLintRule {
  static const ruleName = 'avoid_unsafe_reduce';

  const AvoidUnsafeReduceRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage: 'Calling .reduce on an empty collection will result in a runtime exception.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final targetType = node.realTarget?.staticType;
      if (targetType == null || !iterableChecker.isAssignableFromType(targetType)) return;
      if (node.methodName.name != 'reduce') return;

      // if (node.parent is ConditionalExpression) {
      //   final expression = node.parent as ConditionalExpression;
      //   final thenExpression = expression.thenExpression;
      //   final elseExpression = expression.elseExpression;
      //   if (expression.condition is! PrefixedIdentifier) return;

      //   final prefix = expression.condition as PrefixedIdentifier;
      //   if ((prefix.toSource().contains('isEmpty')) && (elseExpression.toSource().contains('reduce'))) return;
      //   if ((prefix.toSource().contains('isNotEmpty')) && (thenExpression.toSource().contains('reduce'))) return;
      // }

      reporter.reportErrorForNode(code, node.methodName);
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidUnsafeReduceFix()];
}

class _AvoidUnsafeReduceFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((MethodInvocation node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Prefer fold with initial value instead.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addSimpleReplacement(node.methodName.sourceRange, 'fold')
          ..addInsertion(
            node.methodName.sourceRange.end + 1,
            (builder) {
              builder.write('0,');
            },
          )
          ..format(node.sourceRange);
      });
    });
  }
}
