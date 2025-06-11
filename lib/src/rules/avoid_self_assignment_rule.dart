// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidSelfAssignmentRule extends DartLintRule {
  const AvoidSelfAssignmentRule()
    : super(
        code: const LintCode(
          name: 'avoid_self_assignment',
          problemMessage: 'Avoid self assignment.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addAssignmentExpression((node) {
      if (node.operator.type != TokenType.EQ) return;
      if (node.leftHandSide.toString() != node.rightHandSide.toString()) return;

      reporter.atNode(node, code);
    });
  }
}
