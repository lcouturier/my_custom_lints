import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidUselessAsyncMethodRule extends DartLintRule {
  const AvoidUselessAsyncMethodRule()
    : super(
        code: const LintCode(
          name: 'avoid_useless_async_method',
          problemMessage: "Unnecessary async method. Remove the 'async' keyword.",
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme.startsWith('_')) return;
      if (!node.body.isAsynchronous) return;

      final visitor = _AwaitFinderVisitor();
      node.visitChildren(visitor);
      if (visitor.hasAwait) return;

      reporter.atNode(node, code);
    });
  }
}

class _AwaitFinderVisitor extends RecursiveAstVisitor<void> {
  int i = 0;
  _AwaitFinderVisitor();

  bool get hasAwait => i > 0;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    i++;
    super.visitAwaitExpression(node);
  }

  @override
  void visitBlockFunctionBody(FunctionBody node) {
    if (node is BlockFunctionBody) {
      node.visitChildren(this);
    }
  }
}
