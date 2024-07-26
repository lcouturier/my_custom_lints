import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoEqualThenElseRule extends DartLintRule {
  static const String lintName = 'no_equal_then_else';

  const NoEqualThenElseRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Then and else branches are equal.',
            correctionMessage: 'Then and else branches are equal.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = _Visitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);

    if (node.elseStatement != null &&
        node.elseStatement is! IfStatement &&
        node.thenStatement.toString() == node.elseStatement.toString()) {
      _nodes.add(node);
    }
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    super.visitConditionalExpression(node);

    if (node.thenExpression.toString() == node.elseExpression.toString()) {
      _nodes.add(node);
    }
  }
}
