// ignore_for_file: avoid_single_cascade_in_expression_statements, cascade_invocations, unused_element

// ignore: unused_import
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidOnlyRethrowRule extends DartLintRule {
  const AvoidOnlyRethrowRule()
      : super(
          code: const LintCode(
            name: 'avoid_only_rethrow',
            problemMessage:
                'Catch clauses with only the rethrow expression should either have some additional code to handle some type of exceptions or can be simply removed since they are redundant.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCatchClause((node) {
      if (node.body.statements.length != 1) return;

      final expr = node.body.statements.first;
      if (expr is! ExpressionStatement) return;
      if (expr.expression is! RethrowExpression) return;

      reporter.reportErrorForNode(code, expr.expression);
    });
  }
}

/// TODO : update dart fix
class _AvoidOnlyRethrowFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addTryStatement((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      if (node.catchClauses.isEmpty) return;
      if (node.catchClauses.length != 1) return;

      final clause = node.catchClauses.first;
      if (clause.body.statements.length != 1) return;
      if (clause.body.statements.first.toSource() != 'rethrow;') return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove the try catch bloc',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addDeletion(range.startEnd(node.beginToken, node.beginToken.next!))
          ..addDeletion(range.startEnd(clause.beginToken.previous!, node.endToken))
          ..format(range.node(node));
      });
    });
  }
}
