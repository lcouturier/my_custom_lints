import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidUnconditionalBreakRule extends DartLintRule {
  const AvoidUnconditionalBreakRule()
    : super(
        code: const LintCode(
          name: 'avoid_unconditional_break',
          problemMessage: 'Warns when a break, continue, return or throw are used unconditionally in a for loop.',
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addContinueStatement((node) {
      final (found, _) = node.getAncestor((e) => e is IfStatement);
      if (found) return;

      reporter.atNode(node, code);
    });

    context.registry.addBreakStatement((node) {
      final (found, _) = node.getAncestor((e) => e is IfStatement);
      if (found) return;

      reporter.atNode(node, code);
    });

    context.registry.addReturnStatement((node) {
      final (found, _) = node.getAncestor((e) => e is IfStatement);
      if (found) return;

      reporter.atNode(node, code);
    });
  }
}
