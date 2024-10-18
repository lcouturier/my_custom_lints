// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoiddNestedRecordRule extends DartLintRule {
  static const lintName = 'avoid_nested_record';

  const AvoiddNestedRecordRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Nesting multiple records can significantly reduce readability.',
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
      bool hasNestedRecord = node.fields.any((e) => e is RecordLiteral);
      if (hasNestedRecord) {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addTypeAlias((node) {
      if (node is! GenericTypeAlias) return;

      final n = node.declaredElement as TypeAliasElement;
      if (n.aliasedType is! RecordType) return;
      final r = n.aliasedType as RecordType;
      bool hasNestedRecord = r.positionalFields.any((e) => e.type is RecordType);
      if (!hasNestedRecord) return;
      reporter.reportErrorForNode(code, node);
    });
  }
}
