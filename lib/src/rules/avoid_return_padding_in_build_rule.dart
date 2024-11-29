// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidReturnPaddingRule extends DartLintRule {
  const AvoidReturnPaddingRule()
      : super(
          code: const LintCode(
            name: 'avoid_return_padding_in_build',
            problemMessage: 'Avoid directly returning Padding in the build method.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedType((node) {
      if (node.name2.lexeme != 'Padding') return;
      final (found, p) = node.getAncestor((e) => e is ReturnStatement);
      if (!found) return;

      final m = p!.thisOrAncestorOfType<MethodDeclaration>();
      if (m == null) return;
      if (m.name.lexeme != 'build') return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
