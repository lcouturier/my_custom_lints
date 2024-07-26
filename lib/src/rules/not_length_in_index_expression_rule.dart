// ignore: unused_import
// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
// ignore: unused_import
import 'package:my_custom_lints/src/common/utils.dart';

class NoLengthInIndexExpression extends DartLintRule {
  const NoLengthInIndexExpression()
      : super(
          code: const LintCode(
            name: 'no_length_in_index_expression',
            problemMessage: '{0} is an error.',
            correctionMessage: 'Consider replacing {1} with {2}.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Register the visitor for index expressions
    context.registry.addIndexExpression((IndexExpression node) {
      final targetType = node.realTarget.staticType;
      if (targetType == null || !listChecker.isAssignableFromType(targetType)) {
        return;
      }

      if (node.index is BinaryExpression) return;
      if (!node.toSource().contains('length')) return;

      if (node.index is PrefixedIdentifier) {
        reporter.reportErrorForNode(
          code,
          node,
          [
            '${node.realTarget.toSource()}[${node.realTarget.toSource()}.length]',
            node.toSource(),
            '${node.realTarget.toSource()}.last',
          ],
        );
      }
    });

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'elementAt') return;
      if (node.argumentList.arguments.length != 1) return;

      final argument = node.argumentList.arguments.first;
      if (!argument.toString().endsWith('.length')) return;

      reporter.reportErrorForNode(
        code,
        node,
        [
          'list.elementAt(0)',
          node.toSource(),
          '${node.realTarget?.toSource()}.first',
        ],
      );
    });
  }

  @override
  List<Fix> getFixes() => [NoLengthInIndexExpressionFix()];
}

class NoLengthInIndexExpressionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIndexExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.last',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final replacement = node.isCascaded ? 'last' : '.last';
        builder.addSimpleReplacement(
          range.startEnd(node.leftBracket, node.rightBracket),
          replacement,
        );
      });
    });

    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.last',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.startEnd(node.methodName, node.argumentList),
          'last',
        );
      });
    });
  }
}
