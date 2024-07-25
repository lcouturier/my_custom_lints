import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Register a callback for each method invocation in the file.
    context.registry.addMethodInvocation((MethodInvocation node) {
      // We get the static element of the method name node.
      final Element? element = node.methodName.staticElement;

      // Check if the method's element is a FunctionElement.
      if (element is! FunctionElement) return;

      // Check if the method name is 'print'.
      if (element.name != 'print') return;

      // Check if the method's library is 'dart:core'.
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
    // Register a callback for each method invocation in the file.
    context.registry.addMethodInvocation((MethodInvocation node) {
      // If the method invocation does not intersect with the analysis error, return.
      if (!node.sourceRange.intersects(analysisError.sourceRange)) return;

      // Create a ChangeBuilder to apply the quick fix.
      // The message is displayed in the quick fix menu.
      // The priority determines the order of the quick fixes in the menu.
      final ChangeBuilder changeBuilder = reporter.createChangeBuilder(
        message: 'Use log from dart:developer instead.',
        priority: 80,
      );

      // Here we use the addDartFileEdit method to apply the quick fix.
      changeBuilder.addDartFileEdit((DartFileEditBuilder builder) {
        // Get the source range of the method name node.
        final sourceRange = node.methodName.sourceRange;

        // Here we ensure that the developer package is imported.
        // It will import the package if it is not already imported.
        // If the package is already imported, it will return a ImportLibraryElementResult object.
        final result = builder.importLibraryElement(Uri.parse('dart:developer'));

        // Get the library prefix if the package is imported.
        final String? prefix = result.prefix;

        // Get the replacement string based on the library prefix.
        final String replacement = prefix != null ? '$prefix.log' : 'log';

        // Replace the print statement with log.
        builder.addSimpleReplacement(sourceRange, replacement);
      });
    });
  }
}
