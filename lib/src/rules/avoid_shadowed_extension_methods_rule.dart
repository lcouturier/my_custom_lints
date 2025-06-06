import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidShadowedExtensionMethodsRule extends DartLintRule {
  const AvoidShadowedExtensionMethodsRule()
    : super(
        code: const LintCode(
          name: 'avoid_shadowed_extension_methods',
          problemMessage: 'Extension target already declares a member with the same name. Try renaming this method.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addExtensionDeclaration((node) {
      final annotation = node.extendedType;
      if (annotation.type?.element is! ClassElement) return;

      final methods = (annotation.type!.element! as ClassElement).methods;
      final extensionMethods = node.members.whereType<MethodDeclaration>();

      final errors = extensionMethods.joinWhere(methods, (p0, p1) => p0.name.lexeme == p1.name, (p0, p1) => p0);
      for (final error in errors) {
        reporter.reportErrorForToken(code, error.name);
      }
    });
  }
}
