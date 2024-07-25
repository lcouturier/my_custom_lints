import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NumberOfParametersRule extends DartLintRule {
  static const problem = 'number_of_parameters';

  const NumberOfParametersRule()
      : super(
          code: const LintCode(
            name: 'number_of_parameters',
            problemMessage: problem,
            correctionMessage: 'Try reducing the number of parameters.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      final parameters = switch (node) {
        (final MethodDeclaration node) => node.parameters?.parameters.length ?? 0,
        (final FunctionDeclaration node) => node.functionExpression.parameters?.parameters.length ?? 0,
        _ => 0,
      };

      if (parameters > 2) {
        reporter.reportErrorForOffset(
          code,
          node.firstTokenAfterCommentAndMetadata.offset,
          node.end,
        );
      }
    });
  }
}
