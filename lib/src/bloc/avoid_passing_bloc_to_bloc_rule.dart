// ignore_for_file: avoid_single_cascade_in_expression_statements, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';
import 'package:my_custom_lints/src/common/checker.dart';

/// https://bloclibrary.dev/architecture/#bloc-to-bloc-communication
class AvoidPassingblocToBlocRule extends DartLintRule {
  const AvoidPassingblocToBlocRule()
    : super(
        code: const LintCode(
          name: 'avoid_passing_bloc_to_bloc',
          problemMessage:
              'Because blocs expose streams, it may be tempting to make a bloc which listens to another bloc. You should not do this. (https://bloclibrary.dev/architecture/#bloc-to-bloc-communication)',
          correctionMessage: '',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclarationBlocAndCubit((node) {
      final fields =
          node.members.whereType<FieldDeclaration>().map((e) => e.fields.variables.toList()).expand((e) => e).toSet();

      final items = fields.where(
        (e) =>
            cubitChecker.isAssignableFromType(e.declaredElement!.type) ||
            blocChecker.isAssignableFromType(e.declaredElement!.type),
      );

      for (final item in items) {
        reporter.reportErrorForNode(code, item);
      }
    });
  }
}
