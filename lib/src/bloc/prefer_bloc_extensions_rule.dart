// ignore_for_file: unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class PreferBlocExtensionsRule extends DartLintRule {
  const PreferBlocExtensionsRule()
    : super(
        code: const LintCode(
          name: 'prefer_bloc_extensions',
          problemMessage:
              "Using context extensions is shorter, helps you keep the codebase consistent and makes it less likely to forget listen: true when watch behavior is expected.",
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'of') return;
      if (node.realTarget?.toString() != 'BlocProvider') return;
      final (found, named) = node.argumentList.arguments.firstWhereOrNot((e) => e.toString().startsWith('listen:'));
      if (found) {
        if (named is! NamedExpression) return;
        if (named.name.label.name != 'listen') return;
        if (named.expression is! BooleanLiteral) return;
      }
      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferBlocExtensionsFix()];
}

class _PreferBlocExtensionsFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Use context extensions', priority: 80);

      final hasWatch = node.argumentList.arguments.any((e) => e.toString() == 'listen: true');
      final context = node.argumentList.arguments.first as SimpleIdentifier;
      final typeArguments = node.typeArguments?.toString() ?? '';

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          range.node(node),
          '${context.name}.${hasWatch ? 'watch' : 'read'}$typeArguments()',
        );
      });
    });
  }
}
