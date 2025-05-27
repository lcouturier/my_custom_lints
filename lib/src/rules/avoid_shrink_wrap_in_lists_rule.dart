import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidShrinkWrapInListRule extends DartLintRule {
  static const lintName = 'avoid_shrink_wrap_in_lists';

  const AvoidShrinkWrapInListRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage:
                'According to the Flutter documentation, using shrinkWrap in lists is expensive performance-wise and should be avoided, since using slivers is significantly cheaper and achieves the same or even better results.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      const listViewChecker = TypeChecker.fromName('ListView', packageName: 'flutter');

      if (!listViewChecker.isExactlyType(node.staticType!)) return;

      if (node.constructorName.type.name2.lexeme != 'ListView') return;
      if (node.argumentList.arguments.isEmpty) return;

      final (found, p) = node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNot((e) => e.name.label.name == 'shrinkWrap');
      if (!found) return;

      if (p!.expression is! BooleanLiteral) return;
      final litteral = p.expression as BooleanLiteral;
      if (!litteral.value) return;

      reporter.reportErrorForNode(code, p);
    });
  }
}
