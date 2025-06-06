import 'package:analyzer/dart/ast/ast.dart';

import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidPlusRule extends DartLintRule {
  const AvoidPlusRule()
    : super(
        code: const LintCode(
          name: 'avoid_plus_usage',
          problemMessage: 'Avoid using plus method.',
          correctionMessage: 'Consider using + operator.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'plus') return;
      if (node.argumentList.arguments.isEmpty) return;
      if (node.argumentList.arguments.whereType<NamedExpression>().any((e) => e.name.label.name != 'element')) return;

      final targetType = node.realTarget?.staticType;
      if (targetType == null || !stringChecker.isAssignableFromType(targetType)) return;

      reporter.reportErrorForNode(code, node.function);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidPlusRuleFix()];
}

class _AvoidPlusRuleFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.function.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Replace with + operator', priority: 80);

      final p = node.argumentList.arguments.first as NamedExpression;

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(
          range.startEnd(node.function.beginToken.previous!, node.argumentList.arguments.endToken!.next!),
          (builder) {
            builder.write(' + ${p.expression}');
          },
        );
      });
    });
  }
}
