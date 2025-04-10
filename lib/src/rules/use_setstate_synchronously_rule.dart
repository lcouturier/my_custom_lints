import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class UseSetStateSynchronouslyRule extends DartLintRule {
  const UseSetStateSynchronouslyRule()
      : super(
          code: const LintCode(
            name: 'use_setstate_synchronously',
            problemMessage: "Don't use setState asynchronously.",
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final declaredElement = node.declaredElement!;
      if (!stateChecker.isSuperOf(declaredElement)) return;

      for (var member in node.members.whereType<MethodDeclaration>().where((e) => e.body.isAsynchronous)) {
        final methodBody = member.body;
        if (methodBody is BlockFunctionBody) {
          final blockVisitor = MethodBlockVisitor(this);
          member.accept(blockVisitor);

          for (final block in blockVisitor.blocks) {
            final hasCheckPoint = _hasCheckPoint(block);
            if (hasCheckPoint) return;

            final (found, next) = _findSetStateCall(block);
            if (found) {
              reporter.atNode(next!, code, data: next);
            }
          }
        }
      }
    });
  }

  bool _hasCheckPoint(Block body) {
    for (var element in body.statements.zipWithNext()) {
      if ((element.current is IfStatement) &&
          (element.current as IfStatement).expression.toSource().contains('!mounted')) {
        final next = element.next;
        if (next is ExpressionStatement &&
            (next.expression is MethodInvocation) &&
            (next.expression as MethodInvocation).methodName.name == 'setState') {
          return true;
        }
      }
    }
    return false;
  }

  (bool, ExpressionStatement?) _findSetStateCall(Block body) {
    final statements = body.statements.whereType<ExpressionStatement>();
    for (final statement in statements.withIndex) {
      if (statement.item.expression is AwaitExpression) {
        final next = statements.elementAtOrNull(statement.index + 1);
        if (next?.expression is MethodInvocation) {
          final method = next!.expression as MethodInvocation;
          if (method.methodName.name == 'setState') {
            return (true, next);
          }
        }
      }
    }
    return (false, null);
  }

  @override
  List<Fix> getFixes() => [_UseSetstateSynchronouslyRuleFix()];
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

class _UseSetstateSynchronouslyRuleFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final expression = analysisError.data! as ExpressionStatement;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Add mounted check',
      priority: 80,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder
        ..addSimpleInsertion(expression.offset, 'if (!mounted) return;')
        ..format(range.node(expression));
    });
  }
}
