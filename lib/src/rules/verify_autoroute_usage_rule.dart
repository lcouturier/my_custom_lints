import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Rule which reports incorrect usage of autoroute router.
/// sample
/// ```dart
/// router.push(DonationCauseDetailRouter(children: [
///     DonationCauseDetailRoute(cause: cause),
///      ]));
/// ```
class VerifyAutoRouteUsageRule extends DartLintRule {
  static const suffixRouter = 'Router';
  static const suffixRoute = 'Route';
  static const paramsRoute = 'children';

  const VerifyAutoRouteUsageRule()
      : super(
          code: const LintCode(
            name: 'verify_autoroute_usage',
            problemMessage: 'Incorrect usage of autoroute router.',
            correctionMessage: 'Ensure the route is correctly defined and used with autoroute.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'push') return;

      final target = node.target;
      if (target is! SimpleIdentifier) return;
      if (target.name != 'router') return;

      final argument = node.argumentList.arguments.first;
      if (argument is! InstanceCreationExpression) return;

      final className = argument.constructorName.type.name2.lexeme;
      if (!className.endsWith(suffixRouter)) return;

      final found =
          argument.argumentList.arguments.any((arg) => arg is NamedExpression && arg.name.label.name == paramsRoute);
      if (!found) return;

      final routeArgument = argument.argumentList.arguments
          .firstWhere((arg) => arg is NamedExpression && arg.name.label.name == paramsRoute);

      final routeList = (routeArgument as NamedExpression).expression as ListLiteral;

      for (final route in routeList.elements
          .whereType<InstanceCreationExpression>()
          .map((e) => e.constructorName.type.name2.lexeme)) {
        if (!route.endsWith(suffixRoute)) {
          reporter.reportErrorForNode(code, node);
          return;
        }

        if (!route.startsWith(className.split(suffixRouter)[0])) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }
}
