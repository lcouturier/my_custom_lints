// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

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
      final m = node.thisOrAncestorOfType<MethodDeclaration>();
      if ((m?.name.lexeme ?? '') == 'build') return;

      if (node.methodName.name != 'watch') return;
      if (node.target?.staticType?.toString() != 'BuildContext') return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
