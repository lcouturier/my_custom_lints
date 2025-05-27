import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidUselessColumnRule extends DartLintRule {
  const AvoidUselessColumnRule()
      : super(
          code: const LintCode(
            name: 'avoid_useless_column',
            problemMessage: 'Avoid useless column.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'Column') return;
      if (node.argumentList.arguments.length > 1) return;
      final children =
          node.argumentList.arguments.firstWhereOrNull((e) => e is NamedExpression && e.name.label.name == 'children');
      if (children == null) return;

      final childrenList = (children as NamedExpression).expression;
      if (childrenList is! ListLiteral) return;

      if (childrenList.elements.any((e) => e is SpreadElement)) return;
      final itemCount = childrenList.elements.length;
      if (itemCount > 1) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
