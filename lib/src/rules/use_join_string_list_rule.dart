// ignore_for_file: cascade_invocations, unused_import, unused_element

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class UseJoinOnStringsRule extends DartLintRule {
  static const ruleName = 'use_join_on_strings';

  const UseJoinOnStringsRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage:
                'join() is designed to concatenate iterable elements into a single string, but it assumes all elements are strings. If an iterable contains non-string types, it will throw an error.',
            errorSeverity: ErrorSeverity.ERROR,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'join') return;

      final target = node.target;
      if (target is! Identifier) return;
      final type = target.staticType;

      if (!(type is InterfaceType && type.isDartCoreList && type.typeArguments.isNotEmpty)) return;
      final typeArgument = type.typeArguments.first;
      if (typeArgument.isDartCoreString) return;

      reporter.reportErrorForNode(code, node.methodName);
    });
  }
}
