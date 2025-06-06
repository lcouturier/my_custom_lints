import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

@Deprecated('Use AvoidBannedUsageRule instead')
class AvoidFilterRule extends DartLintRule {
  const AvoidFilterRule()
    : super(
        code: const LintCode(
          name: 'avoid_filter_usage',
          problemMessage: 'Avoid using filter.',
          correctionMessage: 'Consider using where method instead.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    // Register a callback for each method invocation in the file.
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'filter') return;

      final target = node.realTarget;
      final targetType = target?.staticType;
      if (targetType == null) return;

      if (!iterableChecker.isAssignableFromType(targetType)) return;

      reporter.reportErrorForNode(code, node.function);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_ReplaceWithIterableWhere()];
}

class _ReplaceWithIterableWhere extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Replace with Iterable.where', priority: 80);

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.methodName.sourceRange, 'where');
      });
    });
  }
}
