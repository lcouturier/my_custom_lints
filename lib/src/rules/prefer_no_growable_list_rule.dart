// ignore_for_file: cascade_invocations, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

/// See: https://medium.com/flutter-senior/always-use-non-growable-arrays-if-possible-4864a022a54a
class PreferNoGrowableListRule extends DartLintRule {
  static const ruleName = 'prefer_no_growable_list';

  const PreferNoGrowableListRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage: 'Always use non-growable arrays if possible.',
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
      if (node.methodName.name != 'toList') return;
      if (node.argumentList.arguments.isNotEmpty) return;

      if (node.parent is ReturnStatement) {
        reporter.reportErrorForNode(code, node.methodName);
        return;
      }

      final method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method != null) {
        /// TODO : traiter le cas des ExpressionFunctionBody
        if (method.body is! BlockFunctionBody) return;
        final body = method.body as BlockFunctionBody;
        for (final statement in body.block.statements.whereType<ExpressionStatement>()) {
          final expression = statement.expression;
          if (expression is MethodInvocation) {
            final targetType = node.realTarget?.staticType;
            if (targetType != null || iterableChecker.isAssignableFromType(targetType!)) {
              if (expression.methodName.name.startsWith('remove') || expression.methodName.name.startsWith('add')) {
                return;
              }
            }
          }
        }
      }

      reporter.reportErrorForNode(code, node.methodName);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferNoGrowableListFix()];
}

class _PreferNoGrowableListFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add growable: false to toList()',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(node.methodName.end + 1, 'growable: false');
      });
    });
  }
}
