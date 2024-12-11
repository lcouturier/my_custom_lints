import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class AvoidPassingbuildContextToBlocsRule extends DartLintRule {
  const AvoidPassingbuildContextToBlocsRule()
      : super(
          code: const LintCode(
            name: 'avoid_passing_build_context_to_blocs',
            problemMessage:
                'Passing BuildContext creates unnecessary coupling between Blocs and widgets and should be avoided. Additionally, depending on BuildContext can introduce tricky bugs when context is not mounted.',
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
    context.registry.addMethodeDeclarationCubit((node) {
      if (node.parameters == null) return;
      if (node.parameters!.parameters.isEmpty) return;
      final (found, value) = node.parameters!.parameters.firstWhereOrNot((p) => p.isBuildContext);

      if (!found) return;
      reporter.reportErrorForNode(code, value!);
    });
  }
}
