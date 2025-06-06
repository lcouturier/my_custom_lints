import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class AvoidGetterPrefixRule extends DartLintRule {
  static const lintName = 'avoid_getter_prefix';

  const AvoidGetterPrefixRule()
    : super(
        code: const LintCode(
          name: 'avoid_getter_prefix',
          problemMessage: 'Avoid a getter name starts with "get" prefix.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addGetterDeclaration((node) {
      if (node.name.lexeme.startsWith('get')) {
        reporter.reportErrorForToken(code, node.name);
      }
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidGetterPrefixFix()];
}

class _AvoidGetterPrefixFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addGetterDeclaration((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Remove get prefix', priority: 80);

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.name.sourceRange, node.name.lexeme.removePrefix().firstLowerCase);
      });
    });
  }
}
