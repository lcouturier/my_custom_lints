// ignore_for_file: avoid_single_cascade_in_expression_statements, cascade_invocations

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidOnlyRethrowRule extends DartLintRule {
  const AvoidOnlyRethrowRule()
      : super(
          code: const LintCode(
            name: 'avoid_only_rethrow',
            problemMessage: 'Avoid only rethrow.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addTryStatement((node) {
      if (node.catchClauses.isEmpty) return;
      if (node.catchClauses.length != 1) return;

      final clause = node.catchClauses.first;
      if (clause.body.statements.length != 1) return;
      if (clause.body.statements.first.toSource() != 'rethrow;') return;

      reporter.reportErrorForNode(code, clause.body.statements.first);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidOnlyRethrowFix()];
}

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
