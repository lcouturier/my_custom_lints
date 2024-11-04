// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

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

      reporter.reportErrorForNode(code, node);
    });
  }
}

class AvoidWatchOutsideBuildRule extends DartLintRule {
  const AvoidWatchOutsideBuildRule()
      : super(
          code: const LintCode(
            name: 'avoid_watch_outside_build',
            problemMessage:
                "Avoid using 'watch' outside of the 'build' method. Try rewriting the code to use 'read' instead.",
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
      if (node.methodName.name != 'watch') return;
      if (node.target?.staticType?.toString() != 'BuildContext') return;

      final m = node.thisOrAncestorOfType<MethodDeclaration>();
      if ((m?.name.lexeme ?? '') == 'build') return;

      reporter.reportErrorForNode(code, node);
    });
  }
}