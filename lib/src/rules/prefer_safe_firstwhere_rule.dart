// ignore_for_file: cascade_invocations, unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferSafeFirstWhereRule extends DartLintRule {
  static const ruleName = 'prefer_safe_first_where';

  const PreferSafeFirstWhereRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage:
                'firstWhere(), lastWhere() and singleWhere() find the first or only element matching a condition, respectively. Both methods throw a StateError if no element matches, and singleWhere() throws an error if more than one element matches.',
            correctionMessage: 'Use the optional orElse parameter to provide a default if no element matches.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const methods = ['firstWhere', 'singleWhere', 'lastWhere'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final targetType = node.realTarget?.staticType;
      if (targetType == null || !iterableChecker.isAssignableFromType(targetType)) return;
      if (!methods.contains(node.methodName.name)) return;
      if (node.argumentList.arguments.length == 2) return;

      reporter.reportErrorForNode(code, node.methodName);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferSafeFirstWhereFix()];
}

class _PreferSafeFirstWhereFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((MethodInvocation node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add orElse parameter.',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addInsertion(node.end - 1, (builder) => builder.write(', orElse: () => null'))
          ..format(node.sourceRange);
      });
    });
  }
}
