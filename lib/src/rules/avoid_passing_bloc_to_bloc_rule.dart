// ignore_for_file: avoid_single_cascade_in_expression_statements, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

/// https://bloclibrary.dev/architecture/#bloc-to-bloc-communication
class AvoidPassingblocToBlocRule extends DartLintRule {
  const AvoidPassingblocToBlocRule()
      : super(
          code: const LintCode(
            name: 'avoid_passing_bloc_to_bloc',
            problemMessage:
                'Because blocs expose streams, it may be tempting to make a bloc which listens to another bloc. You should not do this.',
            correctionMessage: '',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (node.extendsClause == null) return;
      if ((!node.isCubit) && (!node.isBloc)) return;

      final fields =
          node.members.whereType<FieldDeclaration>().map((e) => e.fields.variables.toList()).expand((e) => e).toSet();

      final items = fields.where((e) =>
          cubitChecker.isAssignableFromType(e.declaredElement!.type) ||
          blocChecker.isAssignableFromType(e.declaredElement!.type));

      for (final item in items) {
        reporter.reportErrorForNode(code, item);
      }
    });
  }
}
