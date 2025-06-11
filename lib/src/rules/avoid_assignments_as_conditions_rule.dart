// ignore_for_file: lines_longer_than_80_chars, cascade_invocations, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidAssignmentsAsConditionsRule extends DartLintRule {
  static const lintName = 'avoid_assignments_as_conditions';

  const AvoidAssignmentsAsConditionsRule()
    : super(
        code: const LintCode(
          name: lintName,
          problemMessage: 'Avoid an assignment inside a condition.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIfStatement((node) {
      if (node.expression is! AssignmentExpression) return;

      reporter.atNode(node, code);
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidAssignmentsAsConditionsFix()];
}

class _AvoidAssignmentsAsConditionsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIfStatement((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove an assignment inside a condition.',
        priority: 80,
      );

      final bloc = node.parent! as Block;
      final assignmentExpression = node.expression as AssignmentExpression;
      final rightEntity = assignmentExpression.rightHandSide;
      final operator = assignmentExpression.operator;
      final flag =
          bloc.statements
              .whereType<VariableDeclarationStatement>()
              .where(
                (e) => e.variables.variables.any(
                  (v) => v.name.lexeme == (assignmentExpression.leftHandSide as SimpleIdentifier).name,
                ),
              )
              .firstOrNull;
      if (flag == null) return;

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addInsertion(flag.end - 1, (builder) {
            builder
              ..write(operator.type == TokenType.QUESTION_QUESTION_EQ ? TokenType.EQ.lexeme : operator.lexeme)
              ..write(rightEntity.toSource());
          })
          ..addDeletion(range.startEnd(operator, rightEntity));
        if (flag.beginToken.next?.type == TokenType.QUESTION) {
          builder.addDeletion(range.token(flag.beginToken.next!));
        }

        builder.format(range.node(bloc));
      });
    });
  }
}
