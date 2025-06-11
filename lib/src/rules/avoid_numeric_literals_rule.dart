// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidNumericLiteralsRule extends DartLintRule {
  const AvoidNumericLiteralsRule()
    : super(
        code: const LintCode(
          name: 'avoid_numeric_literals',
          problemMessage: 'avoid numeric literals',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIntegerLiteral((node) {
      if (node.inConstantContext) return;
      if (node.parent is IndexExpression) return;
      if (node.parent is TypedLiteral) return;
      if (node.thisOrAncestorMatching((e) => e is VariableDeclaration) != null) return;
      if (node.thisOrAncestorMatching((e) => e is InstanceCreationExpression && e.isConst) != null) return;
      if (node.thisOrAncestorMatching((e) => e is EnumConstantArguments) != null) return;
      if (node.thisOrAncestorMatching(
            (e) =>
                e is InstanceCreationExpression && e.staticType?.getDisplayString(withNullability: false) == 'DateTime',
          ) !=
          null)
        return;
      if (node.thisOrAncestorMatching(
            (e) =>
                e is InstanceCreationExpression && e.staticType?.getDisplayString(withNullability: false) == 'Duration',
          ) !=
          null)
        return;

      reporter.atNode(node, code);
    });
  }
}
