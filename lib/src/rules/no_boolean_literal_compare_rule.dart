import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = _Visitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }

  @override
  List<Fix> getFixes() => [NoBooleanLiteralCompareFix()];
}

class _Visitor extends RecursiveAstVisitor<void> {
  static const _scannedTokenTypes = {TokenType.EQ_EQ, TokenType.BANG_EQ};

  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    if (!_scannedTokenTypes.contains(node.operator.type)) {
      return;
    }

    if ((node.leftOperand is BooleanLiteral && _isTypeBoolean(node.rightOperand.staticType)) ||
        (_isTypeBoolean(node.leftOperand.staticType) && node.rightOperand is BooleanLiteral)) {
      _nodes.add(node);
    }
  }

  bool _isTypeBoolean(DartType? type) => type != null && type.isDartCoreBool && !isNullableType(type);
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
      final useDirect = (node.operator.type == TokenType.EQ_EQ && booleanLiteralOperand == 'true') ||
          (node.operator.type == TokenType.BANG_EQ && booleanLiteralOperand == 'false');

      final changeBuilder = reporter.createChangeBuilder(
        message: useDirect ? 'Just use it directly' : 'Just negate it',
        priority: 80,
      );

      final correction = (leftOperandBooleanLiteral ? node.rightOperand : node.leftOperand).toString();

      final range = node.sourceRange;
      changeBuilder.addDartFileEdit((builder) {
        final replacement = useDirect ? correction : '!$correction';
        builder.addSimpleReplacement(
          range,
          replacement,
        );
      });
    });
  }
}
