import 'package:analyzer/dart/ast/ast.dart';
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
      final parameters = node.functionExpression.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      if (parameters.isEmpty) return;

      _analyzeAssignment(context, parameters, reporter);
    });

    context.registry.addMethodDeclaration((node) {
      final parameters = node.parameters?.parameters.map((e) => e.name?.lexeme ?? '') ?? [];
      if (parameters.isEmpty) return;

      _analyzeAssignment(context, parameters, reporter);
    });
  }

  void _analyzeAssignment(CustomLintContext context, Iterable<String> parameters, ErrorReporter reporter) {
    context.registry.addAssignmentExpression((node) {
      final leftHandSide = node.leftHandSide;

      if (leftHandSide is SimpleIdentifier && parameters.contains(leftHandSide.name)) {
        reporter.reportErrorForNode(code, node);
      } else {
        if (leftHandSide is PrefixedIdentifier && parameters.contains(leftHandSide.prefix.name)) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }
}
