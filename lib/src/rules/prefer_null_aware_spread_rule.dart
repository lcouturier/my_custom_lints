// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class PreferNullAwareSpreadRule extends DartLintRule {
  const PreferNullAwareSpreadRule()
      : super(
          code: const LintCode(
            name: 'prefer_null_aware_spread',
            problemMessage:
                'when a null check inside a collection literal can be replaced with a null-aware spread (...?).',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addLiteralSpreadItem((node, name) {
      log("addLiteralSpreadItem  : $name");
      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferNullAwareSpreadFix()];
}

class _PreferNullAwareSpreadFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addLiteralSpreadItem((node, name) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with null-aware spread',
        priority: 80,
      );
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(range.node(node), '...?$name');
      });
    });
  }
}
