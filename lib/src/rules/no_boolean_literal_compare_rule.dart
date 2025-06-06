import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class NoBooleanLiteralCompareRule extends DartLintRule {
  static const problem =
      'Comparing boolean values to boolean literals is unnecessary, as those expressions will result in booleans too. Just use the boolean values directly or negate them.';

  const NoBooleanLiteralCompareRule()
    : super(
        code: const LintCode(
          name: 'no_boolean_literal_compare',
          problemMessage: problem,
          correctionMessage: problem,
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addBooleanLiteral((node) {
      final parent = node.parent;
      if (parent is! BinaryExpression) return;
      if (parent.operator.type != TokenType.EQ_EQ && parent.operator.type != TokenType.BANG_EQ) return;

      if ((parent.leftOperand is BooleanLiteral && isBoolType(parent.rightOperand.staticType)) ||
          (parent.rightOperand is BooleanLiteral && isBoolType(parent.leftOperand.staticType))) {
        reporter.reportErrorForNode(code, parent);
      }
    });
  }

  bool isBoolType(DartType? type) => type != null && type.isDartCoreBool && !isNullableType(type);

  @override
  List<Fix> getFixes() => [NoBooleanLiteralCompareFix()];
}

class NoBooleanLiteralCompareFix extends DartFix {
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

      final leftOperandBooleanLiteral = node.leftOperand is BooleanLiteral;
      final booleanLiteralOperand = (leftOperandBooleanLiteral ? node.leftOperand : node.rightOperand).toString();
      final useDirect =
          (node.operator.type == TokenType.EQ_EQ && booleanLiteralOperand == 'true') ||
          (node.operator.type == TokenType.BANG_EQ && booleanLiteralOperand == 'false');

      final changeBuilder = reporter.createChangeBuilder(
        message: useDirect ? 'Just use it directly' : 'Just negate it',
        priority: 80,
      );

      final correction = (leftOperandBooleanLiteral ? node.rightOperand : node.leftOperand).toString();

      final range = node.sourceRange;
      changeBuilder.addDartFileEdit((builder) {
        final replacement = useDirect ? correction : '!$correction';
        builder.addSimpleReplacement(range, replacement);
      });
    });
  }
}
