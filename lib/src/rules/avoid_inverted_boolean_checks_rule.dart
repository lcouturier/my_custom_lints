// ignore_for_file: cascade_invocations, unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidInvertedBooleanChecksRule extends DartLintRule {
  const AvoidInvertedBooleanChecksRule()
      : super(
          code: const LintCode(
            name: 'avoid_inverted_boolean_checks',
            problemMessage: 'Avoid using inverted boolean checks.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPrefixExpression((node) {
      if (node.operator.type != TokenType.BANG) return;
      if (node.operand is! ParenthesizedExpression) return;
      final operand = node.operand as ParenthesizedExpression;
      if (operand.expression is! BinaryExpression) return;
      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidInvertedBooleanChecksFix()];
}

class _AvoidInvertedBooleanChecksFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPrefixExpression((node) {
      final expression = node.operand;
      if (expression is! ParenthesizedExpression) return;
      final binary = expression.expression as BinaryExpression;

      if (!analysisError.sourceRange.covers(node.sourceRange)) return;
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Invert boolean operator',
        priority: 80,
      );

      if ((binary.leftOperand is! BinaryExpression) && (binary.rightOperand is! BinaryExpression)) {
        final (token, _) = binary.operator.type.invert;
        changeBuilder.addDartFileEdit((builder) {
          builder.addReplacement(
            range.node(node),
            (builder) {
              builder
                ..write(binary.leftOperand.toSource())
                ..write(token.lexeme)
                ..write(binary.rightOperand.toSource());
            },
          );
          builder.format(range.node(node));
        });
      }

      if ((binary.leftOperand is BinaryExpression) && (binary.rightOperand is BinaryExpression)) {
        // final (token, _) = binary.operator.type.invert;
        final bl = binary.leftOperand as BinaryExpression;
        final br = binary.rightOperand as BinaryExpression;
        changeBuilder.addDartFileEdit((builder) {
          builder.addDeletion(range.entity(node.operator));
          builder.addDeletion(range.entity((node.operand as ParenthesizedExpression).leftParenthesis));
          builder.addDeletion(range.entity((node.operand as ParenthesizedExpression).rightParenthesis));
          builder.addReplacement(
            range.node(binary.leftOperand),
            (builder) {
              builder
                ..write(bl.leftOperand.toSource())
                ..write(bl.operator.type.invert.$1.lexeme)
                ..write(bl.rightOperand.toSource());
            },
          );
          builder.addReplacement(
            range.startEnd(binary.operator, binary.operator),
            (builder) => builder.write(binary.operator.type.invert.$1.lexeme),
          );
          builder.addReplacement(
            range.node(binary.rightOperand),
            (builder) {
              builder
                ..write(br.leftOperand.toSource())
                ..write(br.operator.type.invert.$1.lexeme)
                ..write(br.rightOperand.toSource());
            },
          );

          builder.format(range.node(node));
        });
      }
    });
  }
}
