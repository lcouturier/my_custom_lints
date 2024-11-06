// ignore_for_file: unused_import

import 'dart:developer';

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
    // Register a callback for each method invocation in the file.
    context.registry.addFunctionDeclaration((node) {
      final parameters = node.functionExpression.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      final visitor = _ParameterMutationChecker(parameters.toList());
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });

    context.registry.addMethodDeclaration((node) {
      final parameters = node.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      final visitor = _ParameterMutationChecker(parameters.toList());
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}

class _ParameterMutationChecker extends RecursiveAstVisitor<void> {
  final List<String> paramNames;
  final nodes = <AstNode>[];

  _ParameterMutationChecker(this.paramNames);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final leftHandSide = node.leftHandSide;

    if (leftHandSide is SimpleIdentifier && paramNames.contains(leftHandSide.name)) {
      nodes.add(node);
    } else {
      if (leftHandSide is PrefixedIdentifier && paramNames.contains(leftHandSide.prefix.name)) {
        nodes.add(node);
      }
    }

    super.visitAssignmentExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier && paramNames.contains(target.name)) {
      nodes.add(node);
    }
    super.visitMethodInvocation(node);
  }
}
