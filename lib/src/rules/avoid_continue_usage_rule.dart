import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidContinueUsage extends DartLintRule {
  const AvoidContinueUsage()
      : super(
          code: const LintCode(
            name: 'avoid_continue_usage',
            problemMessage: 'The continue statement is not allowed in this context.',
            correctionMessage: '',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addContinueStatement((node) {
      reporter.reportErrorForNode(code, node);
    });
  }
}
