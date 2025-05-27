// ignore_for_file: cascade_invocations, avoid_unused_constructor_parameters, unused_element

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidPositionalRecordFieldAccessRule extends DartLintRule {
  static const lintName = 'avoid_positional_record_field_access';

  const AvoidPositionalRecordFieldAccessRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage:
                'consider destructuring (final (x, y) = ...) the record first or converting its fields to named fields',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPropertyAccess((node) {
      final targetType = node.realTarget.staticType;
      if (targetType is! RecordType) return;

      final propertyName = node.propertyName.name;
      if (!propertyName.startsWith(r'$')) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
