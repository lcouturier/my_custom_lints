// ignore_for_file: pattern_never_matches_value_type

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidEmptyBuildWhenRule extends DartLintRule {
  static const lintName = 'avoid_empty_build_when';

  const AvoidEmptyBuildWhenRule()
    : super(
        code: const LintCode(
          name: lintName,
          problemMessage: 'a BlocBuilder or BlocConsumer does not specify the buildWhen condition.',
          correctionMessage: 'Specifying buildWhen helps avoid unnecessary rebuilds and improves overall performance.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  static final _instanceNames = ['BlocBuilder', 'BlocConsumer'];

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (!_instanceNames.contains(node.constructorName.type.name2.lexeme)) return;
      final found = node.argumentList.arguments.whereType<NamedExpression>().any(
        (e) => e.name.label.name == 'buildWhen',
      );
      if (found) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }
}
