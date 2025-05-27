// ignore_for_file: unused_local_variable, unused_element

import 'dart:core';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidInvalidPrefixRule extends DartLintRule {
  const AvoidInvalidPrefixRule()
      : super(
          code: const LintCode(
            name: 'avoid_invalid_prefix',
            problemMessage: 'Consider remove the {0} prefix.',
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
      final nameWithoutUnderscore = node.name.lexeme.startsWith('_') ? node.name.lexeme.substring(1) : node.name.lexeme;
      if (nameWithoutUnderscore.toLowerCase().contains('enum')) {
        reporter.reportErrorForToken(code, node.beginToken.next!, ['Enum']);
      }

      final prefix = node.name.lexeme.splitOnUppercase().first.toLowerCase();
      for (var e in node.constants) {
        if (e.name.lexeme.toLowerCase().contains(prefix)) {
          reporter.reportErrorForNode(code, e, [prefix], [], (e, prefix));
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => <Fix>[_AvoidInvalidPrefixFix()];
}

class _AvoidInvalidPrefixFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addEnumDeclaration((node) {
      if (analysisError.sourceRange.covers(node.beginToken.next!.sourceRange)) {
        final changeBuilder = reporter.createChangeBuilder(
          message: 'Remove Enum prefix',
          priority: 80,
        );

        final prefix = node.name.lexeme.startsWith('_') ? '_Enum' : 'Enum';

        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleReplacement(
            node.beginToken.next!.sourceRange,
            node.beginToken.next!.lexeme.removePrefix(prefix),
          );
        });
      } else {
        if (analysisError.data != null) {
          final (value, prefix) = analysisError.data! as (EnumConstantDeclaration constant, String prefix);

          final changeBuilder = reporter.createChangeBuilder(
            message: 'Remove $prefix prefix',
            priority: 80,
          );
          // ignore: cascade_invocations
          changeBuilder.addDartFileEdit((builder) {
            builder.addSimpleReplacement(
              value.sourceRange,
              value.name.lexeme.removePrefix(prefix),
            );
          });
        }
      }
    });
  }
}
