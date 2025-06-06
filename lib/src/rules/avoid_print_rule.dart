// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/names.dart';

class AvoidPrintRule extends DartLintRule {
  const AvoidPrintRule()
    : super(
        code: const LintCode(
          name: RuleNames.avoidPrint,
          problemMessage: 'Avoid using print statements in production code.',
          correctionMessage: 'Consider using a logger instead.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.staticElement;
      if (element is! FunctionElement) return;
      if (element.name != 'print') return;
      if (!element.library.isDartCore) return;

      // Report the lint error for the method invocation node.
      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[UseDeveloperLogFix()];
}

class UseDeveloperLogFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Use log from dart:developer instead.', priority: 80);

      changeBuilder.addDartFileEdit((builder) {
        final sourceRange = node.methodName.sourceRange;

        final result = builder.importLibraryElement(Uri.parse('dart:developer'));
        final prefix = result.prefix;
        final replacement = prefix != null ? '$prefix.log' : 'log';

        builder.addSimpleReplacement(sourceRange, replacement);
      });
    });
  }
}
