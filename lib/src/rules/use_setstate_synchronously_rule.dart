// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class UseSetStateSynchronouslyRule extends DartLintRule {
  const UseSetStateSynchronouslyRule()
      : super(
          code: const LintCode(
            name: 'use_setstate_synchronously',
            problemMessage: "Don't use setState asynchronously.",
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlockFunctionBody((node) {
      final body = node.block;

      final hasCheckPoint = _hasCheckPoint(body);
      if (hasCheckPoint) return;

      final (found, next) = _findSetStateCall(body);
      if (found) {
        reporter.reportErrorForNode(code, next!, [], [], next);
      }
    });
  }

  bool _hasCheckPoint(Block body) {
    for (var element in body.statements.withIndex) {
      if ((element.item is IfStatement) && (element.item as IfStatement).expression.toSource().contains('!mounted')) {
        final next = body.statements.elementAtOrNull(element.index + 1);
        if (next is ExpressionStatement &&
            (next.expression is MethodInvocation) &&
            (next.expression as MethodInvocation).methodName.name == 'setState') {
          return true;
        }
      }
    }
    return false;
  }

  (bool, ExpressionStatement?) _findSetStateCall(Block body) {
    final statements = body.statements.whereType<ExpressionStatement>();
    for (final statement in statements.withIndex) {
      if (statement.item.expression is AwaitExpression) {
        final next = statements.elementAtOrNull(statement.index + 1);
        if (next?.expression is MethodInvocation) {
          final method = next!.expression as MethodInvocation;
          if (method.methodName.name == 'setState') {
            return (true, next);
          }
        }
      }
    }
    return (false, null);
  }

  @override
  List<Fix> getFixes() => [_UseSetstateSynchronouslyRuleFix()];
}

class _UseSetstateSynchronouslyRuleFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final expression = analysisError.data! as ExpressionStatement;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Add mounted check',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder
        ..addSimpleInsertion(expression.offset, 'if (!mounted) return;')
        ..format(range.node(expression));
    });
  }
}
