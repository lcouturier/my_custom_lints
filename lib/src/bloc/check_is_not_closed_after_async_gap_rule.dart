import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';

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
    context.registry.addBlocAndCubitAsyncMethods((methods) {
      for (var method in methods) {
        final awaitFinder = _AwaitFinder();
        method.accept(awaitFinder);
        if (awaitFinder.awaitExpressions.isEmpty) return;

        final emitFinder = _EmitFinder();
        method.accept(emitFinder);

        for (final emitNode in emitFinder.emitInvocations) {
          bool needToCheck = false;
          for (final awaitExpr in awaitFinder.awaitExpressions) {
            if (_hasToVerify(emitNode, awaitExpr)) {
              needToCheck = true;
              break;
            }
          }

          if (needToCheck && !_isEmitProtectedByClosedCheck(emitNode)) {
            reporter.atNode(emitNode, code, data: emitNode);
          }
        }
      }
    });
  }

  bool _isEmitProtectedByClosedCheck(MethodInvocation node) {
    AstNode? currentNode = node.parent;

    while (currentNode != null) {
      if (currentNode is IfStatement) {
        if (currentNode.expression is PrefixExpression && currentNode.expression.toSource().contains('isClosed')) {
          return true;
        }
      }

      if (currentNode is ExpressionStatement && currentNode.expression is AwaitExpression) {
        return false;
      }

      if (currentNode is ReturnStatement || currentNode is BreakStatement || currentNode is ContinueStatement) {
        return false;
      }

      if (currentNode is MethodDeclaration) {
        return false;
      }

      currentNode = currentNode.parent;
    }

    return false;
  }

  bool _hasToVerify(MethodInvocation emitNode, AwaitExpression awaitExpr) {
    if (emitNode.offset < awaitExpr.offset) {
      return false;
    }

    final (emitFound, emitBranch) = _findContainingBranch(emitNode);
    final (awaitFound, awaitBranch) = _findContainingBranch(awaitExpr);

    return !(emitFound && awaitFound && emitBranch!.parent == awaitBranch!.parent && emitBranch != awaitBranch);
  }

  (bool, AstNode?) _findContainingBranch(AstNode node) {
    AstNode? current = node;
    while (current != null) {
      if (current.parent is IfStatement) {
        final ifStmt = current.parent! as IfStatement;
        if (current == ifStmt.thenStatement) {
          return (true, current);
        } else if (current == ifStmt.elseStatement) {
          return (true, current);
        }
      }

      if (current is MethodDeclaration) {
        break;
      }

      current = current.parent;
    }

    return (false, null);
  }

  @override
  List<Fix> getFixes() => [_CheckIsNotClosedAfterAsyncGapFix()];
}

class _AwaitFinder extends RecursiveAstVisitor<void> {
  final List<AwaitExpression> awaitExpressions = [];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitExpressions.add(node);
    super.visitAwaitExpression(node);
  }
}

class _EmitFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> emitInvocations = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'emit') {
      emitInvocations.add(node);
    }
    super.visitMethodInvocation(node);
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
    final expression = analysisError.data! as MethodInvocation;

    reporter.createChangeBuilder(message: 'Add isClosed check', priority: 80).addDartFileEdit((builder) {
      builder.addReplacement(range.node(expression), (builder) {
        builder.write('if (!isClosed) {\n  ${expression.toSource()};\n}');
      });
      builder.format(range.node(expression));
    });
    // });
  }
}
