import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/names.dart';

class PreferReturningConditionRule extends DartLintRule {
  static const problem = 'Returning boolean literal inside if-else statement is redundant.';
  static const correction = 'Prefer return condition itself.';

  const PreferReturningConditionRule()
    : super(
        code: const LintCode(
          name: RuleNames.preferReturningCondition,
          problemMessage: problem,
          correctionMessage: correction,
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIfStatement((node) {
      final thenStatement = node.thenStatement;
      final elseStatement = node.elseStatement;

      final thenExpr = _extractReturnExpression(thenStatement);
      final elseExpr = _extractReturnExpression(elseStatement);

      if (thenExpr is BooleanLiteral && elseExpr is BooleanLiteral) {
        final inverted = !thenExpr.value && elseExpr.value;
        reporter.reportErrorForNode(code, node, null, null, (node, inverted));
      }
    });
  }

  Expression? _extractReturnExpression(Statement? statement) {
    if (statement is Block) {
      final internal = statement.statements.singleOrNull;
      if (internal is ReturnStatement) {
        return internal.expression;
      }
    } else if (statement is ReturnStatement) {
      return statement.expression;
    }
    return null;
  }

  @override
  List<Fix> getFixes() => [PreferReturningConditionFix()];
}

class PreferReturningConditionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final data = analysisError.data;
    if (data is (IfStatement, bool)) {
      final node = data.$1;
      final isInverted = data.$2;

      final range = node.sourceRange;
      final replacement = 'return ${isInverted ? '!' : ''}${node.expression};';

      reporter
          .createChangeBuilder(priority: 10, message: 'Return condition')
          .addDartFileEdit((b) => b.addSimpleReplacement(range, replacement));
    }
  }
}
