import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidMutatingParametersRule extends DartLintRule {
  const AvoidMutatingParametersRule()
      : super(
          code: const LintCode(
            name: 'avoid_mutating_parameters',
            problemMessage: "a parameter's field or setter is reassigned.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      List<AstNode> nodes = [];
      final parameters = node.functionExpression.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      if (parameters.isEmpty) return;

      final visitor = RecursiveAssignmentVisitor(
        paramNames: parameters.toList(),
        onVisitAssignment: (node) => nodes.add(node),
      );
      node.accept(visitor);

      for (final element in nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });

    context.registry.addMethodDeclaration((node) {
      List<AstNode> nodes = [];
      final parameters = node.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      if (parameters.isEmpty) return;

      final visitor = RecursiveAssignmentVisitor(
        paramNames: parameters.toList(),
        onVisitAssignment: (node) => nodes.add(node),
      );
      node.accept(visitor);

      for (final element in nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}

class RecursiveAssignmentVisitor extends RecursiveAstVisitor<void> {
  const RecursiveAssignmentVisitor({
    required this.onVisitAssignment,
    required this.paramNames,
  });

  final void Function(AstNode node) onVisitAssignment;
  final List<String> paramNames;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final leftHandSide = node.leftHandSide;

    if (leftHandSide is SimpleIdentifier && paramNames.contains(leftHandSide.name)) {
      onVisitAssignment(node);
    } else {
      if (leftHandSide is PrefixedIdentifier && paramNames.contains(leftHandSide.prefix.name)) {
        onVisitAssignment(node);
      }
    }
    super.visitAssignmentExpression(node);
  }
}
