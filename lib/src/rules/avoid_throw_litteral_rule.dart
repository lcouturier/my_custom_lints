import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

@Deprecated('Use PreferThrowExceptionOrErrorRule instead')
class AvoidThrowLiteral extends DartLintRule {
  const AvoidThrowLiteral()
    : super(
        code: const LintCode(
          name: 'avoid_throw_literal',
          problemMessage: 'Throwing literal is an anti-pattern. Use throw Exception() instead.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addThrowExpression((node) {
      if (node.expression is! Literal) return;
      reporter.reportErrorForNode(code, node);
    });
  }
}
