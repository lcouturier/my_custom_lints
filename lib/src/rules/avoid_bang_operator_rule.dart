import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Rule which forbids to use a bang operator ("!")
/// as it may result in unexpected runtime exceptions.
class AvoidBangOperatorRule extends DartLintRule {
  static const problem = 'Avoid using "!" operator';

  const AvoidBangOperatorRule()
      : super(
          code: const LintCode(
            name: 'avoid_bang_operator',
            problemMessage: problem,
            correctionMessage: problem,
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPostfixExpression((node) {
      if (node.operator.type == TokenType.BANG) {
        reporter.reportErrorForToken(code, node.operator);
      }
    });
  }
}
