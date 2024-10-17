import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidEmptySetStateRule extends DartLintRule {
  const AvoidEmptySetStateRule()
      : super(
          code: const LintCode(
            name: 'avoid_empty_set_state',
            problemMessage:
                'Calling setState with an empty callback will still cause the widget to be re-rendered, but since it does not change the state, an empty callback is usually a sign of a bug.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'setState') return;

      final argument = node.argumentList.arguments.first;
      if (argument is! FunctionExpression) return;

      if (argument.body is! BlockFunctionBody) return;
      final body = argument.body as BlockFunctionBody;
      if (body.block.statements.isNotEmpty) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
