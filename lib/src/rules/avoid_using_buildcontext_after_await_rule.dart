// ignore_for_file: avoid_single_cascade_in_expression_statements, unused_import

import 'dart:async';
import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/copy_with_utils.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidUsingBuildContextAwaitRule extends DartLintRule {
  const AvoidUsingBuildContextAwaitRule()
      : super(
          code: const LintCode(
            name: 'avoid_using_buildcontext_after_await',
            problemMessage: 'Avoid using BuildContext after an await in async functions.',
            correctionMessage: 'Using BuildContext after await can lead to accessing an unmounted widget.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      final body = node.body;
      if (body is! BlockFunctionBody) return;
      final context = node.parameters?.parameters.firstWhereOrNull((p) => p.isBuildContext);
      if (context == null) return;

      final statements = body.block.statements.whereType<ExpressionStatement>();
      for (final statement in statements.indexed) {
        if (statement.$2.expression is AwaitExpression) {
          final next = statements.elementAtOrNull(statement.$1 + 1);
          if (next?.expression is MethodInvocation) {
            final m = next!.expression as MethodInvocation;
            if (!m.toSource().contains(context.name?.lexeme ?? '')) return;

            reporter.reportErrorForNode(code, next, [], [], next);
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [
        /// TODO(add fix): add dart fix
      ];
}
