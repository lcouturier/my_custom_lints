import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidLocalFunctionRule extends DartLintRule {
  const AvoidLocalFunctionRule()
    : super(
        code: const LintCode(
          name: 'avoid_local_function',
          problemMessage: 'Avoid local function.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addBlockFunctionBody((node) {
      final statements = node.block.statements;
      for (final statement in statements.whereType<FunctionDeclarationStatement>()) {
        reporter.reportErrorForNode(code, statement);
      }
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidLocalFunctionFix()];
}

class _AvoidLocalFunctionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFunctionDeclaration((node) {
      final body = node.functionExpression.body;
      if (body is! BlockFunctionBody) return;

      for (final statement in body.block.statements.whereType<FunctionDeclarationStatement>()) {
        final changeBuilder = reporter.createChangeBuilder(message: 'Move local function below', priority: 80);

        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          builder
            ..addInsertion(node.end + 2, (builder) {
              if (statement.beginToken.precedingComments != null) {
                builder.write(statement.beginToken.precedingComments!.lexeme);
              }
              builder.write('\n${statement.toSource()}');
            })
            ..addDeletion(
              range.startEnd(statement.beginToken.precedingComments ?? statement.beginToken, statement.endToken),
            );
        });
      }
    });
  }
}
