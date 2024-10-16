// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:collection/collection.dart';

class EnumConstantsOrderingRule extends DartLintRule {
  const EnumConstantsOrderingRule()
      : super(
          code: const LintCode(
            name: 'enum_constants_ordering',
            problemMessage: 'Ensures consistent alphabetical order of Enum constants..',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addEnumDeclaration((node) {
      final initialValues = node.constants.map((e) => e.name.lexeme).where((e) => e != 'none').toList();
      final orderingValues = initialValues.sorted().toList();
      if (initialValues.equals(orderingValues)) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_EnumConstantsOrderingFix()];
}

class _EnumConstantsOrderingFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addEnumDeclaration((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Reorder enum constants',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final none = node.constants.map((e) => e.name.lexeme).firstWhere((e) => e == 'none', orElse: () => '');
        final constants =
            node.constants.map((e) => e.name.lexeme).where((e) => e != 'none').toList().sorted().join(', ');

        builder
          ..addSimpleReplacement(range.startEnd(node.constants.beginToken!, node.constants.endToken!),
              ' ${none.isNotEmpty ? 'none, ' : ''} $constants ')
          ..format(range.startEnd(node.constants.beginToken!, node.constants.endToken!));
      });
    });
  }
}
