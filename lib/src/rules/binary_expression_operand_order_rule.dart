// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class BinaryExpressionOperandOrderRule extends DartLintRule {
  static const ruleName = 'binary_expression_operand_order';

  const BinaryExpressionOperandOrderRule()
    : super(
        code: const LintCode(
          name: ruleName,
          problemMessage: '{0} is on the left-hand side in binary expressions.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  static final _operators = [
    TokenType.PLUS,
    TokenType.MINUS,
    TokenType.SLASH,
    TokenType.STAR,
    TokenType.AMPERSAND,
    TokenType.BAR,
    TokenType.CARET,
  ];

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addBinaryExpression((node) {
      if (node.leftOperand is! IntegerLiteral || node.leftOperand is DoubleLiteral) return;
      if (node.rightOperand is! Identifier) return;
      if (!_operators.contains(node.operator.type)) return;

      reporter.reportErrorForNode(code, node, [node.leftOperand.toSource()]);
    });
  }

  @override
  List<Fix> getFixes() => [_BinaryExpressionOperandOrderRule()];
}

class _BinaryExpressionOperandOrderRule extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addBinaryExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Invert expression order', priority: 80);

      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(node), (builder) {
          builder
            ..write(node.rightOperand.toSource())
            ..write(' ')
            ..write(node.operator.lexeme)
            ..write(' ')
            ..write(node.leftOperand.toSource());
        });
      });
    });
  }
}
