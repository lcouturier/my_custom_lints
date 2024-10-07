// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

/// Lint to add missing fields to equatable props
class MissingFieldInEquatableProps extends DartLintRule {
  /// [MissingFieldInEquatableProps] constructor

  const MissingFieldInEquatableProps()
      : super(
          code: const LintCode(
            name: 'equatable_props_check',
            problemMessage: 'All fields of an Equatable class should be included in the props getter.',
            correctionMessage: 'The following fields are missing from the props getter: {0}',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addEquatableClassFieldDeclaration(({
      required FieldElement fieldElement,
      required ClassDeclaration classNode,
      required List<String> equatablePropsExpressionDetails,
      Expression? propsReturnExpression,
    }) {
      final found = equatablePropsExpressionDetails.contains(fieldElement.displayName);
      if (!found) {
        reporter.reportErrorForNode(
          code,
          propsReturnExpression!,
          [fieldElement.displayName],
        );
      }
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
    context.registry.addEquatableClassFieldDeclaration(({
      required FieldElement fieldElement,
      required ClassDeclaration classNode,
      required List<String> equatablePropsExpressionDetails,
      Expression? propsReturnExpression,
    }) {
      final found = equatablePropsExpressionDetails.contains(fieldElement.displayName);
      if (!found) {
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Add  ${fieldElement.displayName} to props getter',
          priority: 80,
        );

        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          // ignore: cascade_invocations
          changeBuilder.addDartFileEdit((builder) {
            builder
              ..addSimpleInsertion(propsReturnExpression!.sourceRange.end - 1, ',')
              ..addSimpleInsertion(propsReturnExpression.sourceRange.end - 1, fieldElement.displayName);
          });
        });
      }
    });
  }
}
