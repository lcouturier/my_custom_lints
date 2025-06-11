import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class FirstInitStateRule extends DartLintRule {
  const FirstInitStateRule()
    : super(
        code: const LintCode(
          name: 'first_init_state',
          problemMessage: 'super.initState() should be called at the start of the initState method.',
          correctionMessage: 'Try placing super.initState() at the start of the initState method.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      final extendsClause = node.extendsClause;
      if (extendsClause == null) return;

      final type = extendsClause.superclass.type;
      if (type == null || !stateChecker.isAssignableFromType(type)) return;

      final body =
          node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'initState')?.body;
      if (body == null || body is! BlockFunctionBody) return;

      final statements = body.block.statements;
      if (statements.isEmpty) return;

      if (statements.first.toSource() == 'super.initState();') return;

      final superInitStateStatement = statements.firstWhereOrNull(
        (statement) => statement.toSource() == 'super.initState();',
      );
      if (superInitStateStatement == null) return;

      reporter.atNode(superInitStateStatement, code);
    });
  }

  @override
  List<Fix> getFixes() => [_PlaceSuperInitStateAtTheStart()];
}

class _PlaceSuperInitStateAtTheStart extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final body =
          node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'initState')?.body;
      if (body == null || body is! BlockFunctionBody) return;

      final statements = body.block.statements;
      if (statements.isEmpty) return;

      final superInitStateStatement = statements.firstWhereOrNull(
        (statement) => statement.toSource() == 'super.initState();',
      );
      if (superInitStateStatement == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Put super.initState() at the start of the initState method',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        final superInitStateStatementIndex = statements.indexOf(superInitStateStatement);
        final firstStatement = statements.first;

        for (var i = superInitStateStatementIndex; i > 0; i--) {
          builder.addSimpleReplacement(statements[i].sourceRange, statements[i - 1].toSource());
        }

        builder.addSimpleReplacement(firstStatement.sourceRange, superInitStateStatement.toSource());
      });
    });
  }
}
