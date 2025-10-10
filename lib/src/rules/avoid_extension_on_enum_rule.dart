// ignore_for_file: unused_import

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidExtensionOnEnumRule extends DartLintRule {
  const AvoidExtensionOnEnumRule()
      : super(
          code: const LintCode(
            name: 'avoid_extension_on_enum',
            problemMessage: 'Extension target already declares a member with the same name. Try renaming this method.',
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    // Register a callback for each method invocation in the file.
    context.registry.addExtensionDeclaration((node) {
      final annotation = node.onClause?.extendedType;
      if (annotation == null) return;

      if (annotation is! NamedType) return;

      final isEnum = annotation.element is EnumElement;
      if (!isEnum) return;

      reporter.atNode(annotation, code);
    });
  }
}
