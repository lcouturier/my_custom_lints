// ignore_for_file: cascade_invocations, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferContainsMethodRule extends DartLintRule {
  static const ruleName = 'prefer_contains_method';

  const PreferContainsMethodRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage:
                'Suggests using .contains instead of .indexOf when checking for the presence of an element.',
            errorSeverity: ErrorSeverity.INFO,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'indexOf') return;
      final targetType = node.realTarget?.staticType;
      if (targetType == null || !listChecker.isAssignableFromType(targetType)) return;
      if (node.parent is! BinaryExpression) return;
      final expression = node.parent! as BinaryExpression;
      if ((expression.operator.type != TokenType.EQ_EQ) && (expression.operator.type != TokenType.BANG_EQ)) return;
      if (expression.rightOperand.toString() != '-1') return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferContainsMethodFix()];
}

class _PreferContainsMethodFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with contains',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final expression = node.parent as BinaryExpression;
        if (expression.operator.type == TokenType.EQ_EQ) {
          builder.addSimpleInsertion(node.offset, '!');
        }

        builder
          ..addSimpleReplacement(range.node(node.methodName), 'contains')
          ..addDeletion(range.startEnd(expression.operator, expression.rightOperand.endToken))
          ..format(range.node(node.parent!));
      });
    });
  }
}
