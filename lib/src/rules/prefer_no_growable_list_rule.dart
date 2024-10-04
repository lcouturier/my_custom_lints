// ignore_for_file: cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

/// See: https://medium.com/flutter-senior/always-use-non-growable-arrays-if-possible-4864a022a54a
class PreferNoGrowableListRule extends DartLintRule {
  static const ruleName = 'prefer_no_growable_list';

  const PreferNoGrowableListRule()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage: 'Always use non-growable arrays if possible.',
            correctionMessage: '',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final targetType = node.realTarget?.staticType;
      if (targetType == null || !iterableChecker.isAssignableFromType(targetType)) {
        return;
      }

      if (node.methodName.name != 'toList') return;
      if (node.argumentList.arguments.isNotEmpty) return;

      reporter.reportErrorForNode(
        code,
        node.methodName,
        [
          node.toSource(),
          '${node.realTarget?.toSource()}.toList(growable: false)',
        ],
        [],
        node.methodName,
      );
    });
  }

  @override
  List<Fix> getFixes() => [_PreferNoGrowableListFix()];
}

class _PreferNoGrowableListFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.covers(node.methodName.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace toList() by toList(growable: false)',
        priority: 80,
      );

      final p = analysisError.data! as SimpleIdentifier;

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(p.offset + p.length + 1, (builder) {
          builder.write('growable: false');
        });
      });
    });
  }
}
