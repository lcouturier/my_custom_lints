import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidNullableListReturnTypeRule extends DartLintRule {
  const AvoidNullableListReturnTypeRule()
      : super(
          code: const LintCode(
            name: 'avoid_nullable_list_return_type',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: 'Avoid nullable list',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addGenericFunctionType((node) {
      if (node.returnType?.type!.isNullableList ?? false) {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addFunctionTypeAlias((node) {
      if (node.returnType?.type!.isNullableList ?? false) {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addMethodDeclaration((node) {
      if (node.returnType?.type!.isNullableList ?? false) {
        reporter.reportErrorForNode(code, node);
      }
    });

    context.registry.addFunctionDeclaration((node) {
      if (node.returnType?.type!.isNullableList ?? false) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
