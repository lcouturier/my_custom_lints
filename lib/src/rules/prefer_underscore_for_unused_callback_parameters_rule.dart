import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferUnderscoreForUnusedCallbackParameters extends DartLintRule {
  const PreferUnderscoreForUnusedCallbackParameters()
      : super(
          code: const LintCode(
            name: 'prefer_underscore_for_unused_callback_parameters',
            problemMessage: 'The callback parameter is not used.',
            correctionMessage: 'Consider using underscores for the unused parameter.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionExpression((node) {
      final parent = node.parent;
      if (parent is FunctionDeclaration) return;

      final parameters = node.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );
      node.body.accept(visitor);

      final items = parameters
          .where((e) => e.declaredElement != null)
          .where((e) => !e.declaredElement!.name.containsOnlyUnderscores)
          .where((e) => !simpleIdentifiers.map((i) => i.staticElement).contains(e.declaredElement));

      for (final p in items) {
        reporter.reportErrorForNode(code, p, [p.name?.lexeme ?? ''], [], p);
      }
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[PreferUnderscoreForUnusedCallbackParametersFix()];
}

class PreferUnderscoreForUnusedCallbackParametersFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addFunctionExpression((node) {
      final p = analysisError.data! as FormalParameter;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace ${p.name?.lexeme ?? 'undefined'} by _',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(range.node(p), '_');
      });
    });
  }
}
