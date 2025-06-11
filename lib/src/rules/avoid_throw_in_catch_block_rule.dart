// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidThrowInCatchBlockRule extends DartLintRule {
  const AvoidThrowInCatchBlockRule()
    : super(
        code: const LintCode(
          name: 'avoid_throw_in_catch_block',
          problemMessage:
              'Calling throw inside a catch block loses the original stack trace and the original exception.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addCatchClause((node) {
      final items = node.body.statements.whereType<ExpressionStatement>();
      for (final item in items.where((e) => e.expression is ThrowExpression)) {
        reporter.atNode(item.expression, code);
      }
    });
  }
}
