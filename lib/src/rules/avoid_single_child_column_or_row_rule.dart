// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidSingleChildColumnOrRowRule extends DartLintRule {
  const AvoidSingleChildColumnOrRowRule()
      : super(
          code: const LintCode(
            name: 'avoid_single_child_column_or_row',
            problemMessage: 'Avoid single child Column or Row.',
            correctionMessage: 'Remove the widget',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const widgets = <String>[
    'Column',
    'Row',
    'Flex',
    'Wrap',
    'SliverList',
    'SliverMainAxisGroup',
    'SliverCrossAxisGroup',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (!widgets.contains(node.constructorName.type.name2.lexeme)) return;
      if (node.argumentList.arguments.isEmpty) return;

      final (found, p) = node.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhereOrNot((e) => e.name.label.name == 'children');
      if (!found) return;

      if (p!.expression is! ListLiteral) return;
      if ((p.expression as ListLiteral).elements.length != 1) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }
}
