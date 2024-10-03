// ignore_for_file: unnecessary_cast, cascade_invocations

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class AvoidDynamicReturnTypeRule extends DartLintRule {
  const AvoidDynamicReturnTypeRule()
      : super(
          code: const LintCode(
            name: 'avoid_dynamic_return_type',
            correctionMessage: 'Préciser le type de retour.',
            errorSeverity: ErrorSeverity.WARNING,
            problemMessage: '',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addGenericFunctionType((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node, [], [], (node, false));
      }
    });

    context.registry.addFunctionTypedFormalParameter((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node, [], [], (node, false));
      }
    });

    context.registry.addMethodDeclaration((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node, [], [], (node, node.body.hasReturnStatement));
      }
    });

    context.registry.addFunctionDeclaration((node) {
      if (node.returnType == null || node.returnType.toString() == 'dynamic') {
        reporter.reportErrorForNode(code, node, [], [], (node, node.functionExpression.body.hasReturnStatement));
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidDynamicReturnTypeFix()];
}

class _AvoidDynamicReturnTypeFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final (node, hasReturnStatement) = analysisError.data! as (AstNode, bool);
    if (hasReturnStatement) return;

    final changeBuilder = reporter.createChangeBuilder(
      message: 'Add return type',
      priority: 80,
    );

    final typeAnnotation = switch (node) {
      FunctionDeclaration _ => node.returnType,
      MethodDeclaration _ => node.returnType,
      GenericFunctionType _ => node.returnType,
      FunctionTypedFormalParameter _ => node.returnType,
      _ => null,
    };

    changeBuilder.addDartFileEdit((builder) {
      if (typeAnnotation == null) {
        builder.addInsertion(node.beginToken.offset, (builder) {
          builder.write('void ');
        });
      } else {
        builder.addReplacement(range.token(node.beginToken), (builder) {
          builder.write('void');
        });
      }
    });
  }
}
