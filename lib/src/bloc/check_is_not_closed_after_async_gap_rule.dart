import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class CheckIsNotClosedAfterAsyncGapEmitRule extends DartLintRule {
  const CheckIsNotClosedAfterAsyncGapEmitRule()
      : super(
          code: const LintCode(
            name: 'check_is_not_closed_after_async_gap_and_emit',
            problemMessage: "Avoid emitting an event after an await point without checking 'isClosed'.",
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclarationBlocAndCubit((node) {
      for (var member in node.members.whereType<MethodDeclaration>().where((e) => e.body.isAsynchronous)) {
        final methodBody = member.body;
        if (methodBody is BlockFunctionBody) {
          final blockVisitor = MethodBlockVisitor(this);
          member.accept(blockVisitor);

          for (final block in blockVisitor.blocks) {
            for (final item in block.statements.zipWithNext()) {
              if (item.current is ExpressionStatement && item.next is ExpressionStatement) {
                final current = item.current as ExpressionStatement;
                final next = item.next as ExpressionStatement;
                if (current.expression is AwaitExpression && next.expression is MethodInvocation) {
                  final methodInvocation = next.expression as MethodInvocation;
                  if (methodInvocation.methodName.name == 'emit') {
                    reporter.atNode(next, code, data: next);
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_CheckIsNotClosedAfterAsyncGapFix()];
}

class MethodBlockVisitor extends RecursiveAstVisitor<void> {
  final LintRule rule;
  final List<Block> blocks = [];

  MethodBlockVisitor(this.rule);

  @override
  void visitBlock(Block node) {
    blocks.add(node);
    super.visitBlock(node);
  }
}

class _CheckIsNotClosedAfterAsyncGapFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final expression = analysisError.data! as ExpressionStatement;

    reporter.createChangeBuilder(message: 'Add isClosed check', priority: 80).addDartFileEdit((builder) {
      builder.addReplacement(range.node(expression), (builder) {
        builder.write('if (!isClosed) {\n  ${expression.expression.toSource()};\n}');
      });
      builder.format(range.node(expression));
    });
    // });
  }
}
