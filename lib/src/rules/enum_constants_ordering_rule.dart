// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/dart/ast/ast.dart';
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

      reporter.reportErrorForToken(code, node.name, [], [], node.constants);
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
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Reorder enum constants',
      priority: 80,
    );

    final nodes = analysisError.data! as NodeList<EnumConstantDeclaration>;

    // Store constant data (name, arguments, original source)
    final constantData = nodes.map((e) {
      return (
        name: e.name.lexeme,
        arguments: e.arguments?.toSource(),
        source: e.toSource(),
      );
    }).toList();

    // Separate 'none' constant
    final noneConstant = constantData.firstWhereOrNull((e) => e.name == 'none');
    final otherConstants = constantData.where((e) => e.name != 'none').toList();

    // Sort other constants alphabetically
    otherConstants.sort((a, b) => a.name.compareTo(b.name));

    // Reconstruct the enum constants string
    final sortedConstantsString = otherConstants.map((c) {
      return c.arguments != null ? '${c.name}${c.arguments}' : c.name;
    }).join(', ');

    // Prepend 'none' constant if it exists
    final finalConstantsString = noneConstant != null
        ? '${noneConstant.name}${noneConstant.arguments ?? ''}${otherConstants.isNotEmpty ? ', ' : ''}$sortedConstantsString'
        : sortedConstantsString;

    changeBuilder.addDartFileEdit((builder) {
      builder
        ..addSimpleReplacement(
          range.startEnd(nodes.beginToken!, nodes.endToken!),
          ' $finalConstantsString ',
        )
        ..format(range.startEnd(nodes.beginToken!, nodes.endToken!));
    });
  }
}
