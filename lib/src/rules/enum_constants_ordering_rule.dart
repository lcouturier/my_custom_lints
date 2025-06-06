// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
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
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
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
    final changeBuilder = reporter.createChangeBuilder(message: 'Reorder enum constants', priority: 80);

    final nodes = analysisError.data! as NodeList<EnumConstantDeclaration>;
    bool hasArguments = nodes.every((e) => e.arguments != null);
    final none = nodes.map((e) => e.name.lexeme).firstWhere((e) => e == 'none', orElse: () => '');
    final constants =
        hasArguments
            ? nodes
                .map((e) => (e.name.lexeme, e.arguments.toString()))
                .where((e) => e.$1 != 'none')
                .toList()
                .sortedBy((e) => e.$1)
                .map((e) => '${e.$1}${e.$2}')
                .join(', ')
            : nodes.map((e) => e.name.lexeme).where((e) => e != 'none').toList().sorted().join(', ');

    changeBuilder.addDartFileEdit((builder) {
      builder
        ..addSimpleReplacement(
          range.startEnd(nodes.beginToken!, nodes.endToken!),
          ' ${none.isNotEmpty ? 'none, ' : ''} $constants ',
        )
        ..format(range.startEnd(nodes.beginToken!, nodes.endToken!));
    });
    // });
  }
}
