import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidReturningValueFromCubitMethodsRule extends DartLintRule {
  const AvoidReturningValueFromCubitMethodsRule()
    : super(
        code: const LintCode(
          name: 'avoid_returning_value_from_cubit_methods',
          problemMessage: 'Listen to a Cubit state change instead',
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodeDeclarationCubit((node) {
      if (node.returnType.toString() == 'void' || node.returnType is VoidType) return;

      reporter.atNode(node, code);
    });
  }
}
