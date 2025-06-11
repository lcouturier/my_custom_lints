import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferThrowExceptionOrErrorRule extends DartLintRule {
  const PreferThrowExceptionOrErrorRule()
    : super(
        code: const LintCode(
          name: 'prefer_throw_exception_or_error',
          problemMessage:
              'Throw Exceptions for recoverable issues and logical problems.Throw Errors for programming mistakes or irrecoverable conditions.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addThrowExpression((node) {
      if (node.expression is Literal) {
        reporter.atNode(node, code);
        return;
      }

      final thrownType = node.expression.staticType;
      if (thrownType == null) return;

      final isException = thrownType.isSubtypeOfType('Exception');
      final isError = thrownType.isSubtypeOfType('Error');

      if (isException || isError) return;
      reporter.atNode(node, code);
    });

    context.registry.addClassDeclaration((node) {
      final currentType = node.declaredElement?.thisType;
      if (currentType == null) return;

      final isException = currentType.isSubtypeOfType('Exception');
      final isError = currentType.isSubtypeOfType('Error');
      if (!isException && !isError) return;

      final className = node.name.lexeme;
      if (_rules.any((e) => e(className))) return;

      reporter.atNode(
        node,
        const LintCode(
          name: 'invalid_prefix_exception_or_error',
          problemMessage: 'Use the Exception or Error suffix in class names for clarity.',
        ),
      );
    });
  }

  static final _rules = <bool Function(String)>[(name) => name.endsWith('Exception'), (name) => name.endsWith('Error')];
}
