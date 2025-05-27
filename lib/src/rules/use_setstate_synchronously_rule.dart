import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class UseSetStateSynchronouslyRule extends DartLintRule {
  const UseSetStateSynchronouslyRule()
      : super(
          code: const LintCode(
            name: 'use_setstate_synchronously',
            problemMessage: "Avoid calling 'setState' past an await point without checking if the widget is mounted.",
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclarationStatefulWidget((node) {
      for (var method in node.members.whereType<MethodDeclaration>().where((e) => e.body.isAsynchronous)) {
        final awaitFinder = _AwaitFinder();
        method.accept(awaitFinder);
        if (awaitFinder.awaitExpressions.isEmpty) return;

        final finder = _SetStateFinder();
        method.accept(finder);

        for (final setStateNode in finder.setStateInovacations) {
          bool needToCheck = false;
          for (final awaitExpr in awaitFinder.awaitExpressions) {
            if (setStateNode.offset > awaitExpr.offset) {
              needToCheck = true;
              break;
            }
          }

          if (needToCheck && (!_isInvocationProtected(setStateNode)) && (!_isProtectedByEarlyReturn(setStateNode))) {
            reporter.atNode(setStateNode, code, data: setStateNode);
          }
        }
      }
    });
  }

  (bool, Block?) _findContainingBlock(AstNode node) {
    AstNode? current = node;
    while (current != null) {
      if (current is Block) {
        return (true, current);
      }
      current = current.parent;
    }
    return (false, null);
  }

  // ignore: unused_element
  bool _isProtectedByEarlyReturn(AstNode setStateNode) {
    final (found, containingBlock) = _findContainingBlock(setStateNode);
    if (!found) return false;

    List<Statement> statementsToCheck = [];
    bool foundAwait = false;

    for (final statement in containingBlock!.statements) {
      if (statement.offset <= setStateNode.offset && setStateNode.end <= statement.end) {
        break;
      }

      if (statement is ExpressionStatement && statement.expression is AwaitExpression) {
        foundAwait = true;
        statementsToCheck.clear();
        continue;
      }

      if (foundAwait) {
        statementsToCheck.add(statement);
      }
    }

    for (final statement in statementsToCheck) {
      if (statement is IfStatement) {
        final condition = statement.expression;
        if (condition is PrefixExpression && condition.operator.type == TokenType.BANG) {
          if ((condition.operand is SimpleIdentifier) && (condition.operand as SimpleIdentifier).name == 'mounted') {
            if (statement.thenStatement is ReturnStatement) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  bool _isInvocationProtected(MethodInvocation node) {
    AstNode? currentNode = node.parent;

    while (currentNode != null) {
      if ((currentNode is IfStatement) && (currentNode.expression.toSource().contains('mounted'))) {
        return true;
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

  @override
  List<Fix> getFixes() => [_UseSetstateSynchronouslyRuleFix()];
}

class _AwaitFinder extends RecursiveAstVisitor<void> {
  final List<AwaitExpression> awaitExpressions = [];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitExpressions.add(node);
    super.visitAwaitExpression(node);
  }
}

class _SetStateFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> setStateInovacations = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState') {
      setStateInovacations.add(node);
    }
    super.visitMethodInvocation(node);
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
    final expression = analysisError.data! as MethodInvocation;

    reporter.createChangeBuilder(message: 'Add mounted check', priority: 80).addDartFileEdit((builder) {
      builder.addReplacement(range.node(expression), (builder) {
        builder.write('if (mounted) {\n  ${expression.toSource()};\n}\n');
      });
      builder.format(range.node(expression));
    });
  }
}
