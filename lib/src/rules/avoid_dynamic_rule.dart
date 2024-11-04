// ignore_for_file: unnecessary_cast, cascade_invocations, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidDynamicRule extends DartLintRule {
  static const ruleName = 'avoid_dynamic';

  const AvoidDynamicRule()
      : super(
          code: const LintCode(
            name: ruleName,
            correctionMessage: 'Avoid using dynamic.',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: 'Using dynamic is considered unsafe since it can easily result in runtime errors.',
          ),
        );

  static List<bool Function(NamedType node)> _rules = [
    (e) => e.type == null,
    (e) => e.type is DynamicType,
    (e) => e.type.toString() == 'dynamic',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedType((node) {
      if (!_rules.any((element) => element(node))) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addReturnType((node, parent) {
      if (node != null) return;

      reporter.reportErrorForNode(
          LintCode(
            name: ruleName,
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: 'Add void type.',
          ),
          parent);
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidDynamicFix()];
}

class _AvoidDynamicFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addReturnType((node, parent) {
      if (!analysisError.sourceRange.covers(parent.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add void keyword',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleInsertion(parent.offset, 'void ');
      });
    });
  }
}
