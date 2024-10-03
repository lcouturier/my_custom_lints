import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

// pas dans les copyWith

class AvoidNullableBooleanRule extends DartLintRule {
  const AvoidNullableBooleanRule()
      : super(
          code: const LintCode(
            name: 'avoid_nullable_boolean',
            problemMessage: 'Avoid usage of nullable boolean.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((MethodDeclaration node) {
      if (node.name.lexeme == 'copyWith') return;
      if (node.parameters == null) return;
      if (node.parameters?.parameters.isEmpty ?? true) return;

      for (final p in node.parameters!.parameters.whereType<SimpleFormalParameter>()) {
        if ((p.type?.type?.isDartCoreBool ?? false) && p.isNullable) {
          reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], p);
        }
      }
    });

    context.registry.addFunctionDeclaration((FunctionDeclaration node) {
      if (node.functionExpression.parameters == null) return;
      if (node.functionExpression.parameters?.parameters.isEmpty ?? true) return;

      for (final p in node.functionExpression.parameters!.parameters.whereType<SimpleFormalParameter>()) {
        if ((p.type?.type?.isDartCoreBool ?? false) && p.isNullable) {
          reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], p);
        }
      }
    });
  }
}
