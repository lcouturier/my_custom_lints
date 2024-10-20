// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidMixingNamedAndPositionalFieldsRule extends DartLintRule {
  static const lintName = 'avoid_mixing_named_and_positional_fields_rule';

  const AvoidMixingNamedAndPositionalFieldsRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Mixing named and positional fields.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addRecordLiteral((node) {
      bool isMixed = node.fields.any((e) => e is NamedExpression) && node.fields.any((e) => e is! NamedExpression);
      if (!isMixed) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
