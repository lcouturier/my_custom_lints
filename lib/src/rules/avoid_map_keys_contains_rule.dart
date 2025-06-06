// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidMapKeysContainsRule extends DartLintRule {
  const AvoidMapKeysContainsRule()
    : super(
        code: const LintCode(
          name: 'avoid_map_keys_contains',
          problemMessage: 'Avoid using keys.contains for map key checks.',
          correctionMessage: 'Use map.containsKey instead for better performance.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'contains') return;

      final target = node.realTarget;
      if (target is! PrefixedIdentifier) return;
      if (target.identifier.name != 'keys') return;
      if (!((target.prefix).staticType?.isDartCoreMap ?? false)) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidMapKeysContainsFix()];
}

class _AvoidMapKeysContainsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Replace with Map.containsKey', priority: 80);

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(node), (builder) {
          builder
            ..write(node.beginToken.lexeme)
            ..write('.containsKey(')
            ..write(node.endToken.previous?.lexeme ?? '')
            ..write(node.endToken.lexeme);
        });
      });
    });
  }
}
