import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:my_custom_lints/src/common/utils.dart';

class CheckIsNotClosedAfterAsyncGapRule extends DartLintRule {
  const CheckIsNotClosedAfterAsyncGapRule()
      : super(
          code: const LintCode(
            name: 'check_is_not_closed_after_async_gap',
            problemMessage: "Avoid emitting an event after an await point without checking 'isClosed'.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static final _types = [
    (ClassElement e) => cubitChecker.isSuperOf(e),
    (ClassElement e) => blocChecker.isSuperOf(e),
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionBody((node) {
      if (node.parent is! MethodDeclaration) return;
      final classDeclaration = node.parent!.thisOrAncestorOfType<ClassDeclaration>();
      if (classDeclaration == null) return;

      final declaredElement = classDeclaration.declaredElement!;
      final isBloc = _types.any((element) => element(declaredElement));
      if (!isBloc) return;

      if (node is! BlockFunctionBody) return;

      final statements = node.block.statements.whereType<ExpressionStatement>();

      for (final statement in statements.indexed) {
        if (statement.$2.expression is AwaitExpression) {
          final next = statements.elementAtOrNull(statement.$1 + 1);
          if (next?.expression is MethodInvocation) {
            final methodInvocation = next!.expression as MethodInvocation;
            if (methodInvocation.methodName.name == 'emit') {
              reporter.reportErrorForNode(code, next, [], [], next);
            }
          }
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [_CheckIsNotClosedAfterAsyncGapFix()];
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
    context.registry.addFunctionBody((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final expression = analysisError.data! as ExpressionStatement;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add isClosed check',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.node(expression), (builder) {
          builder
            ..write('if (!isClosed) {')
            ..write('${expression.expression.toSource()};')
            ..write('}');
        });
        builder.format(range.node(expression));
      });
    });
  }
}
