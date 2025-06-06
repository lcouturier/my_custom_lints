import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AddCubitSuffixRule extends DartLintRule {
  const AddCubitSuffixRule()
    : super(
        code: const LintCode(
          name: 'add_cubit_suffix_rule',
          problemMessage: 'Consider add cubit suffix.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addCubitClassDeclaration((node) {
      if (node.name.lexeme.endsWith('Cubit')) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
