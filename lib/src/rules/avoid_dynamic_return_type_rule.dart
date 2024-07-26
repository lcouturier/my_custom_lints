import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidDynamicReturnTypeRule extends DartLintRule {
  const AvoidDynamicReturnTypeRule()
      : super(
          code: const LintCode(
            name: 'avoid_dynamic_return_type',
            correctionMessage: 'Préciser le type de retour.',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: '',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addGenericFunctionType((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addFunctionTypeAlias((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addMethodDeclaration((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addFunctionDeclaration((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
