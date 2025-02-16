import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:my_custom_lints/src/common/checker.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class CheckIsNotClosedAfterAsyncGapRule extends DartLintRule {
  const CheckIsNotClosedAfterAsyncGapRule()
      : super(
          code: const LintCode(
            name: 'check_is_not_closed_after_async_gap',
            problemMessage: "Avoid emitting an event after an await point without checking 'isClosed'.",
          ),
        );

  static final _types = <bool Function(ClassElement)>[
    (e) => cubitChecker.isSuperOf(e),
    (e) => blocChecker.isSuperOf(e),
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlockFunctionBody((node) {
      if (node.parent is! MethodDeclaration) return;
      final classDeclaration = node.parent!.thisOrAncestorOfType<ClassDeclaration>();
      if (classDeclaration == null) return;

      final declaredElement = classDeclaration.declaredElement!;
      final isBloc = _types.any((element) => element(declaredElement));
      if (!isBloc) return;

      final statements = node.block.statements.whereType<ExpressionStatement>();

      for (final statement in statements.withIndex) {
        if (statement.item.expression is AwaitExpression) {
          final next = statements.elementAtOrNull(statement.index + 1);
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
    // });
  }
}
