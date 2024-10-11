import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

/// Lint to add missing fields to equatable props
class AlwaysCallSuperPropsRule extends DartLintRule {
  /// [AlwaysCallSuperPropsRule] constructor

  const AlwaysCallSuperPropsRule()
      : super(
          code: const LintCode(
            name: 'always_call_super_props_when_overriding_equatable_props',
            problemMessage: 'Dont forget to call super.props when overriding equatable props.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addEquatableSuperClassDeclaration((node, details) {
      reporter.reportErrorForNode(code, node, ['super.props']);
    });
  }

  @override
  List<Fix> getFixes() => [CallSuperInOverridedEquatableProps()];
}

class CallSuperInOverridedEquatableProps extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addEquatableSuperClassDeclaration(
      (node, _) {
        if (!analysisError.sourceRange.covers(node.sourceRange)) return;

        final changeBuilder = reporter.createChangeBuilder(
          message: 'Add ...super.props to props getter',
          priority: 80,
        );

        // ignore: cascade_invocations
        changeBuilder.addDartFileEdit((builder) {
          builder.addSimpleInsertion(node.beginToken.offset + 1, '...super.props,');
        });
      },
    );
  }
}

extension LintRuleNodeRegistryExtensions on LintRuleNodeRegistry {
  void addEquatableSuperClassDeclaration(
      void Function(
        ListLiteral node,
        List<String> equatablePropsExpressionDetails,
      ) listener) {
    addClassDeclaration((node) {
      final classSuperTypeElement = node.declaredElement!.supertype?.element;
      if (classSuperTypeElement == null) {
        return;
      }
      final (found, _) = classSuperTypeElement.accessors.firstWhereOrNot(
        (e) => e.hasOverride && e.isGetter && e.name == 'props',
      );
      if (!found) return;

      final propsReturnExpression = node.getPropsReturnExpression();
      if (propsReturnExpression == null) return;

      final expression = propsReturnExpression as ListLiteral;

      final doesPropsCallSuper = expression.elements.any((element) => element.toString().contains('super.props'));
      if (doesPropsCallSuper) {
        return;
      }

      final fields = expression.getFieldsFromProps();
      listener(expression, fields);
    });
  }
}
