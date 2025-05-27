import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UnnecessaryToListRule extends DartLintRule {
  const UnnecessaryToListRule()
      : super(
          code: const LintCode(
            name: 'unnecessary_to_list',
            problemMessage: 'Unnecessary use of .toList() with spread operator. Remove .toList() as it is not needed.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSpreadElement(
      (node) {
        if (node.expression is! MethodInvocation) return;

        final methodInvocation = node.expression as MethodInvocation;
        if (methodInvocation.methodName.name == 'toList' && methodInvocation.target != null) {
          reporter.atNode(methodInvocation, code);
        }
      },
    );
  }
}
