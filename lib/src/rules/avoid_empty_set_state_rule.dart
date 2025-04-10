import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidEmptySetStateRule extends DartLintRule {
  const AvoidEmptySetStateRule()
      : super(
          code: const LintCode(
            name: 'avoid_empty_set_state',
            problemMessage:
                'Calling setState with an empty callback will still cause the widget to be re-rendered, but since it does not change the state, an empty callback is usually a sign of a bug.',
            errorSeverity: ErrorSeverity.WARNING,
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

      for (var member in node.members.whereType<MethodDeclaration>()) {
        final methodBody = member.body;
        if (methodBody is BlockFunctionBody) {
          final blockVisitor = MethodBlockVisitor(this);
          member.accept(blockVisitor);

          for (final block in blockVisitor.blocks) {
            for (final statement in block.statements) {
              if (statement is ExpressionStatement) {
                final expression = statement.expression;
                if (expression is MethodInvocation) {
                  verifyMethod(reporter, expression);
                }
              }
            }
          }
        }
      }
    });
  }

  void verifyMethod(ErrorReporter reporter, MethodInvocation node) {
    if (node.methodName.name != 'setState') return;

    final argument = node.argumentList.arguments.first;
    if (argument is! FunctionExpression) return;

    if (argument.body is! BlockFunctionBody) return;
    final body = argument.body as BlockFunctionBody;
    if (body.block.statements.isNotEmpty) return;

    reporter.atNode(node, code);
  }
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
