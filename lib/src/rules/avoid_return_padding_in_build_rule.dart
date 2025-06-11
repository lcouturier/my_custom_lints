import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidReturnPaddingRule extends DartLintRule {
  const AvoidReturnPaddingRule()
    : super(
        code: const LintCode(
          name: 'avoid_return_padding_in_build',
          problemMessage: 'Avoid directly returning Padding in the build method.',
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme == 'Container') {
        if (node.parent is! ReturnStatement) return;
        final found = node.argumentList.arguments.whereType<NamedExpression>().any(
          (e) => e.name.label.name == 'padding',
        );
        if (!found) return;

        final m = node.thisOrAncestorOfType<MethodDeclaration>();
        if (m == null) return;
        if (m.name.lexeme != 'build') return;

        reporter.atNode(node.constructorName, code);
      }
      if (node.constructorName.type.name2.lexeme == 'Padding') {
        if (node.parent is! ReturnStatement) return;

        final m = node.thisOrAncestorOfType<MethodDeclaration>();
        if (m == null) return;
        if (m.name.lexeme != 'build') return;
        reporter.atNode(node.constructorName, code);
      }
    });
  }
}
