import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferImmediateReturnRule extends DartLintRule {
  const PreferImmediateReturnRule()
      : super(
          code: const LintCode(
            name: 'prefer_immediate_return',
            problemMessage:
                'Prefer returning the result immediately instead of declaring an intermediate variable right before the return statement.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionBody((node) {
      if (node is! BlockFunctionBody) return;

      final body = node;
      final length = body.block.statements.length;
      if (length < 2) return;

      final variableStatement = body.block.statements[length - 2];
      final returnStatement = body.block.statements.last;
      if (variableStatement is! VariableDeclarationStatement || returnStatement is! ReturnStatement) return;

      final returnIdentifier = returnStatement.expression;
      if (returnIdentifier is! SimpleIdentifier) return;

      final lastVariable = variableStatement.variables.variables.last;
      if (returnIdentifier.name != lastVariable.name.lexeme) return;

      reporter.reportErrorForNode(code, returnStatement, [], [], body.block);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferImmediateReturnFix()];
}

class _PreferImmediateReturnFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final node = analysisError.data! as Block;
    if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Prefer immediate return',
      priority: 80,
    );

    final length = node.statements.length;
    if (length < 2) return;

    final variableStatement = node.statements[length - 2] as VariableDeclarationStatement;
    final returnStatement = node.statements.last;

    final lastVariable = variableStatement.variables.variables.last;
    final expression = lastVariable.initializer;
    if (expression == null) return;

    changeBuilder.addDartFileEdit((builder) {
      builder
        ..addSimpleReplacement(variableStatement.sourceRange, 'return ${expression.toSource()};')
        ..addDeletion(range.node(returnStatement))
        ..format(node.sourceRange);
    });
  }
}
