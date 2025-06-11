import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UseTernaryInsteadOfIfElse extends DartLintRule {
  const UseTernaryInsteadOfIfElse()
    : super(
        code: const LintCode(
          name: 'use_ternary_instead_of_if_else',
          problemMessage: 'Use ternary operator instead of if-else for simple assignments',
          correctionMessage: 'Suggests replacing if-else with ternary operator.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIfStatement((node) {
      if (node.elseStatement is Block &&
          node.thenStatement is Block &&
          (node.expression is Identifier ||
              (node.expression is PrefixExpression && ((node.expression as PrefixExpression).operand is Identifier)) &&
                  (node.expression as PrefixExpression).operator.type == TokenType.BANG)) {
        final thenBlock = node.thenStatement as Block;
        final elseBlock = node.elseStatement! as Block;

        // Ensure both blocks only contain print statements
        if (thenBlock.statements.length == 1 &&
            elseBlock.statements.length == 1 &&
            thenBlock.statements.first is ExpressionStatement &&
            elseBlock.statements.first is ExpressionStatement) {
          final thenInvocation = thenBlock.statements.first as ExpressionStatement;
          final elseInvocation = elseBlock.statements.first as ExpressionStatement;

          // Check that both are print expressions
          if (thenInvocation.expression is MethodInvocation && elseInvocation.expression is MethodInvocation) {
            final thenMethod = thenInvocation.expression as MethodInvocation;
            final elseMethod = elseInvocation.expression as MethodInvocation;

            if (thenMethod.methodName.name == elseMethod.methodName.name &&
                (thenMethod.methodName.name != 'emit') &&
                thenMethod.argumentList.arguments.length == elseMethod.argumentList.arguments.length &&
                thenMethod.argumentList.arguments.length == 1) {
              reporter.atNode(node, code);
            }
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [UseTernaryInsteadOfIfElseFix()];
}

class UseTernaryInsteadOfIfElseFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIfStatement((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Replace with ternary operator', priority: 80);

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(node), (builder) {
          final thenStatement = (node.thenStatement as Block).statements.first as ExpressionStatement;
          final elseStatement = (node.elseStatement! as Block).statements.first as ExpressionStatement;
          final first = (thenStatement.expression as MethodInvocation).argumentList.arguments.first as Identifier;
          final second = (elseStatement.expression as MethodInvocation).argumentList.arguments.first as Identifier;

          final isNegative =
              (node.expression is PrefixExpression) &&
              (node.expression as PrefixExpression).operator.type == TokenType.BANG;

          builder
            ..write((thenStatement.expression as MethodInvocation).methodName.name)
            ..write('(${isNegative ? (node.expression as PrefixExpression).operand : node.expression}')
            ..write(' ? ')
            ..write(isNegative ? second.name : first.name)
            ..write(' : ')
            ..write('${isNegative ? first.name : second.name});');
        });
      });
    });
  }
}
