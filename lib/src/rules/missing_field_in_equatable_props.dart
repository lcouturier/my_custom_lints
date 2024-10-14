import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class MissingFieldInEquatablePropsRule extends DartLintRule {
  const MissingFieldInEquatablePropsRule()
      : super(
          code: const LintCode(
            name: 'equatable_props_check',
            problemMessage: 'All fields of an Equatable class should be included in the props getter.',
            errorSeverity: ErrorSeverity.WARNING,
            correctionMessage: 'Add {0} to props getter.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addEquatableProps((node, watchableFields, missingFields) {
      reporter.reportErrorForNode(code, node, [missingFields.join(', ')]);
    });
  }

  @override
  List<Fix> getFixes() => [MissingFieldInEquatablePropsFix()];
}

class MissingFieldInEquatablePropsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addEquatableProps((node, watchableFields, missingFields) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add ${missingFields.join(', ')} to props getter',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addReplacement(range.startEnd(node.beginToken.next!, node.endToken.previous!), (builder) {
          builder.write(watchableFields.join(', '));
        });
      });
    });
  }
}
