// ignore_for_file: unnecessary_cast, cascade_invocations, unused_element, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidDynamicRule extends DartLintRule {
  const AvoidDynamicRule()
      : super(
          code: const LintCode(
            name: 'avoid_dynamic',
            correctionMessage: 'Avoid using dynamic.',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: 'Using dynamic is considered unsafe since it can easily result in runtime errors.',
          ),
        );

  static const codeAddVoid =
      LintCode(name: 'avoid_dynamic', errorSeverity: ErrorSeverity.WARNING, problemMessage: 'Add void type.');

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addReturnType((node, parent) {
      if (node == null) {
        reporter.reportErrorForNode(codeAddVoid, parent);
        return;
      }
      if (node.type == null) {
        reporter.reportErrorForNode(code, node);
        return;
      }
      if (node.type is DynamicType) {
        reporter.reportErrorForNode(code, node);
        return;
      }
      if (node.type.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node);
        return;
      }

      if (node.type is RecordType) {
        for (final field in (node.type! as RecordType).positionalFields) {
          if (field.type is DynamicType) reporter.reportErrorForNode(code, node);
        }
        for (final field in (node.type! as RecordType).namedFields) {
          if (field.type is DynamicType) reporter.reportErrorForNode(code, node);
        }
        return;
      }
    });

    context.registry.addFormalParameterList((node) {
      for (final p in node.parameters.where((e) => e.isDynamic)) {
        reporter.reportErrorForNode(code, p);
      }
    });

    context.registry.addVariableDeclaration((node) {
      if (node.declaredElement?.type is DynamicType) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
