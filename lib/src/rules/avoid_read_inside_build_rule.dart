// ignore_for_file: unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidReadInsideBuildRule extends DartLintRule {
  const AvoidReadInsideBuildRule()
      : super(
          code: const LintCode(
            name: 'avoid_read_inside_build',
            problemMessage:
                "Avoid using 'read' inside the 'build' method. Try rewriting the code to use 'watch' instead.",
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
      if (node.methodName.name != 'read') return;
      if (node.target?.staticType?.toString() != 'BuildContext') return;

      final m = node.thisOrAncestorOfType<MethodDeclaration>();
      if ((m?.name.lexeme ?? '') != 'build') return;

      if (node.parent is PropertyAccess) {
        final prop = node.parent! as PropertyAccess;
        if (_isEventHandler(prop.parent)) return;
      }

      if (node.parent is MethodInvocation) {
        final method = node.parent! as MethodInvocation;
        if (_isEventHandler(method.parent)) return;
      }

      reporter.reportErrorForNode(code, node);
    });
  }

  bool _isEventHandler(AstNode? node) {
    if (node == null) return false;
    if (node is NamedExpression) {
      return node.toString().startsWith('on') && (node.expression.staticType?.isCallbackType ?? false);
    }

    AstNode? p = node.parent;
    while (p != null && p is! NamedExpression) {
      p = p.parent;
    }

    return (p is NamedExpression) &&
        p.name.label.name.startsWith('on') &&
        (p.expression.staticType?.isCallbackType ?? false);
  }
}
