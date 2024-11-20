import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

@Deprecated('Use avoid_banned_type rule instead.')
class AvoidCachedNetworkImage extends DartLintRule {
  const AvoidCachedNetworkImage()
      : super(
          code: const LintCode(
            name: 'avoid_cached_network_image',
            problemMessage: 'Avoid using CachedNetworkImage.',
            correctionMessage: 'For testability, use ConfigurableNetworkImage instead.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme == 'CachedNetworkImage') {
        reporter.reportErrorForNode(code, node.constructorName);
      }
    });
  }
}
