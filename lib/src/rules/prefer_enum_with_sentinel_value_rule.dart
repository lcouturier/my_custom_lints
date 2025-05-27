// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferEnumWithSentinelValueRule extends DartLintRule {
  static const sentinelNames = ['uninitialized', 'unknown', 'none'];

  const PreferEnumWithSentinelValueRule()
      : super(
          code: const LintCode(
            name: 'prefer_enum_with_sentinel_value',
            problemMessage: 'Ensure that enums have a sentinel value.',
            correctionMessage: 'Add a sentinel value to the enum like `uninitialized`, `none` or `unknown`.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addEnumDeclaration((node) {
      bool hasSentinel = node.constants.any((e) => sentinelNames.contains(e.name.lexeme));
      if (hasSentinel) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
