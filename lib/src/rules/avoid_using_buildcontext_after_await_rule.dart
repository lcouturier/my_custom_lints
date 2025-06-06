// ignore_for_file: avoid_single_cascade_in_expression_statements, unused_import

import 'dart:async';
import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/copy_with_utils.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidUsingBuildContextAwaitRule extends DartLintRule {
  const AvoidUsingBuildContextAwaitRule()
    : super(
        code: const LintCode(
          name: 'avoid_using_buildcontext_after_await',
          problemMessage: 'Avoid using BuildContext after an await in async functions.',
          correctionMessage: 'Using BuildContext after await can lead to accessing an unmounted widget.',
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodDeclaration((node) {
      final body = node.body;
      if (body is! BlockFunctionBody) return;
      final context = node.parameters?.parameters.firstWhereOrNull((p) => p.isBuildContext);
      if (context == null) return;

      final statements = body.block.statements.whereType<ExpressionStatement>();
      for (final statement in statements.withIndex) {
        if (statement.item.expression is AwaitExpression) {
          final next = statements.elementAtOrNull(statement.index + 1);
          if (next?.expression is MethodInvocation) {
            final m = next!.expression as MethodInvocation;
            if (!m.toSource().contains(context.name?.lexeme ?? '')) return;

            reporter.reportErrorForNode(code, next, [], [], (next, context));
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidUsingBuildContextAwaitFix()];
}

class _AvoidUsingBuildContextAwaitFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFunctionBody((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final (expression, context) = analysisError.data! as (ExpressionStatement, FormalParameter);

      final changeBuilder = reporter.createChangeBuilder(message: 'Add mounted check', priority: 80);

      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(expression), (builder) {
          builder
            ..write('if (${context.name?.lexeme ?? ''}.mounted) {')
            ..write('${expression.expression.toSource()};')
            ..write('}');
        });
        builder.format(range.node(expression));
      });
    });
  }
}
