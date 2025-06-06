// ignore_for_file: pattern_never_matches_value_type, unused_element

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class PreferMultiBlocProviderRule extends DartLintRule {
  static const lintName = 'prefer_multi_bloc_provider';

  const PreferMultiBlocProviderRule()
    : super(
        code: const LintCode(
          name: lintName,
          problemMessage: 'Avoid nested BlocProvider. Consider flattening the structure.',
          correctionMessage: 'Flatten the BlocProvider structure with a MultiBlocProvider.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'BlocProvider') return;
      final (found, value) = node.argumentList.arguments.firstWhereOrNot(
        (e) => e is NamedExpression && e.name.label.name == 'child',
      );
      if (!found) return;
      final childArgument = value! as NamedExpression;

      if (childArgument.expression is! InstanceCreationExpression) return;
      final childExpression = childArgument.expression as InstanceCreationExpression;
      if (childExpression.constructorName.type.name2.lexeme != 'BlocProvider') return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }
}
