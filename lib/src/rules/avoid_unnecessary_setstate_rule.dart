// ignore_for_file: unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidUnnecessarySetStateRule extends DartLintRule {
  const AvoidUnnecessarySetStateRule()
      : super(
          code: const LintCode(
            name: 'avoid_unnecessary_setstate',
            problemMessage:
                "Warns when setState is called inside initState, didUpdateWidget or build methods and when it's called from a sync method that is called inside those methods.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const methods = ['initState', 'didUpdateWidget', 'build'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'setState') return;
      final m = node.thisOrAncestorOfType<MethodDeclaration>();
      if (!methods.contains((m?.name.lexeme ?? ''))) return;

      if ((m?.name.lexeme ?? '') == 'build') {
        if (node.parent is ExpressionStatement) {
          final method = node.parent! as ExpressionStatement;
          if (_isEventHandler(method.parent)) return;
        }
      }

      reporter.reportErrorForNode(code, node);
    });
  }

  bool _isEventHandler(AstNode? node) {
    if (node == null) return false;

    final (found, p) = node.getAncestor((e) => e is NamedExpression);

    return (found && p is NamedExpression) &&
        p.name.label.name.startsWith('on') &&
        (p.expression.staticType?.isCallbackType ?? false);
  }

  @override
  List<Fix> getFixes() => [_AvoidUnnecessarySetStateFix()];
}

class _AvoidUnnecessarySetStateFix extends DartFix {
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
        message: 'Remove unnecessary setState',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(range.startEnd(node.beginToken, node.endToken.next!));
      });
    });
  }
}
