// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const listChecker = TypeChecker.fromUrl('dart:core#List');

class PreferIterableFirst extends DartLintRule {
  static const ruleName = 'prefer_iterable_first';

  const PreferIterableFirst()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage: '{0} is more verbose than iterable.first.',
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
    context.registry.addIndexExpression((node) {
      final targetType = node.realTarget.staticType;
      if (targetType == null || !listChecker.isAssignableFromType(targetType)) return;

      final indexExpression = node.index;
      if (indexExpression is! IntegerLiteral || indexExpression.value != 0) return;

      reporter.reportErrorForNode(code, node, [
        'list[0]',
        node.toSource(),
        '${node.realTarget.toSource()}.first',
      ]);
    });

    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'elementAt') return;

      if (node.argumentList.arguments.length != 1) return;

      final argument = node.argumentList.arguments.first;
      if (argument is! IntegerLiteral || argument.value != 0) return;

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
  List<Fix> getFixes() => [PreferIterableFirstFix()];
}

class PreferIterableFirstFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final node = analysisError.data! as IndexExpression;
    if (!analysisError.sourceRange.covers(node.sourceRange)) return;

    context.registry.addIndexExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.first',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final replacement = node.isCascaded ? 'first' : '.first';
        builder.addSimpleReplacement(
          range.startEnd(node.leftBracket, node.rightBracket),
          replacement,
        );
      });
    });

    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with iterable.first',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.startEnd(node.methodName, node.argumentList),
          'first',
        );
      });
    });
  }
}
