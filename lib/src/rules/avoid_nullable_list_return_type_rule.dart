import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidNullableListReturnTypeRule extends DartLintRule {
  const AvoidNullableListReturnTypeRule()
      : super(
          code: const LintCode(
            name: 'avoid_nullable_list_return_type',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage:
                'Instead of returning a nullable list, consider returning an empty list when there are no items to return. This approach simplifies the handling of the list and avoids the pitfalls associated with null values.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addReturnType((node, parent) {
      if (node == null) return;
      if (node.type == null) return;
      if (node.type!.isNullableList) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
