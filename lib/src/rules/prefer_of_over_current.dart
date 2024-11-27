// ignore_for_file: pattern_never_matches_value_type, unused_element

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferOfOverCurrentRule extends DartLintRule with ContextName {
  static const lintName = 'prefer_of_over_current';
  static const String badWay = 'I18n.current.';
  static const String goodWay = 'I18n.of(context).';

  const PreferOfOverCurrentRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Do not use anymore $badWay',
            correctionMessage: 'Prefer {0}.',
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
      final expression = node.toString();
      if (!expression.startsWith(badWay)) return;

      final (hasFix, name) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      final replacement = node.toString().replaceFirst(badWay, 'I18n.of($name).');
      reporter.reportErrorForNode(
        code,
        node,
        [node.toString().replaceFirst(badWay, replacement)],
      );
    });
    context.registry.addPropertyAccess((node) {
      final expression = node.toString();
      if (!expression.startsWith(badWay)) return;

      final (hasFix, name) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );
      if (!hasFix) return;

      final replacement = node.toString().replaceFirst(badWay, 'I18n.of($name).');
      reporter.reportErrorForNode(
        code,
        node,
        [node.toString().replaceFirst(badWay, replacement)],
      );
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_PreferOfOverCurrentFix()];
}

class _PreferOfOverCurrentFix extends DartFix with ContextName {
  static const String badWay = 'I18n.current.';

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addPropertyAccess((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final (hasFix, paramName) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );

      if (!hasFix) return;

      final replacement = node.toString().replaceFirst(badWay, 'I18n.of($paramName).');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace $node by $replacement',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.sourceRange, replacement);
      });
    });

    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final (hasFix, paramName) = getContextName(
        () => node.thisOrAncestorOfType<MethodDeclaration>(),
        () => node.thisOrAncestorOfType<FunctionDeclaration>(),
      );
      if (!hasFix) return;

      final replacement = node.toString().replaceFirst(badWay, 'I18n.of($paramName).');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace $node by $replacement',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.sourceRange, replacement);
      });
    });
  }
}

mixin ContextName {
  (bool, String) getContextName(
    MethodDeclaration? Function() getMethod,
    FunctionDeclaration? Function() getFunction,
  ) {
    final method = getMethod();

    if (method != null) {
      final parameters = method.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');

      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    final function = getFunction();
    if (function != null) {
      final parameters = function.functionExpression.parameters?.parameters;
      if (parameters == null || parameters.isEmpty) return (false, '');
      return parameters.firstWhereOrElse(
        (e) => e.isBuildContext,
        (e) => (true, e.toString().split(' ')[1]),
        () => (false, ''),
      );
    }

    return (false, '');
  }
}
