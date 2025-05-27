// ignore_for_file: unused_import, cascade_invocations

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferUsageOfValueGetterRule extends DartLintRule {
  const PreferUsageOfValueGetterRule()
      : super(
          code: const LintCode(
            name: 'prefer_usage_of_value_getter',
            problemMessage: 'Consider using a ValueGetter<T>.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFormalParameter((node) {
      if (node is! SimpleFormalParameter) return;
      if (node.name?.lexeme.startsWith('ValueGetter') ?? false) return;
      if (node.type is! GenericFunctionType) return;
      final f = node.type! as GenericFunctionType;
      if (f.parameters.parameters.isNotEmpty) return;
      if (f.returnType is DynamicType) return;
      if (f.returnType is VoidType) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferUsageOfValueGetterFix()];
}

class _PreferUsageOfValueGetterFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFormalParameter((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final replacement =
          'ValueGetter<${(node.declaredElement!.type as FunctionType).returnType}>${node.isNullable ? '?' : ''} ${node.declaredElement!.name}';

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace with $replacement',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..importLibraryElement(Uri.parse('package:flutter/material.dart'))
          ..addSimpleReplacement(
            node.sourceRange,
            replacement,
          );
      });
    });
  }
}
