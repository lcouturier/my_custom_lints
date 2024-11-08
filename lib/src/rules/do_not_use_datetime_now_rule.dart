// ignore_for_file: cascade_invocations, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class DoNotUseDatetimeNowRule extends DartLintRule {
  const DoNotUseDatetimeNowRule()
      : super(
          code: const LintCode(
            name: 'do_not_use_datetime_now_in_tests',
            problemMessage: 'Do not use DateTime.now() in tests.',
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
      if (node.name2.lexeme != 'DateTime') return;
      if (node.parent is! ConstructorName) return;

      final constructName = node.parent as ConstructorName;
      if (constructName.name?.name != 'now') return;

      final m = node.thisOrAncestorOfType<MethodInvocation>();
      if (m == null) return;
      if (m.methodName.name != 'test') return;

      reporter.reportErrorForNode(code, node.parent!);
    });
  }
}
