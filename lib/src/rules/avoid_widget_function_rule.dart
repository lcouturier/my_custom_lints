// ignore_for_file: unused_element, unused_import, prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';
import 'package:my_custom_lints/src/names.dart';

class AvoidWidgetFunctionRule extends DartLintRule {
  const AvoidWidgetFunctionRule()
      : super(
          code: const LintCode(
            name: 'avoid_widget_function',
            problemMessage: 'Avoid building widgets with functions.',
            correctionMessage: 'Wrap this call by a builder.',
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
      final returnType = node.staticType;

      if (returnType == null) return;
      if (!returnType.isWidget) return;

      final namedExpression = _getNamedExpression(node) as NamedExpression?;
      if (namedExpression?.name.label.name == 'builder') return;

      reporter.reportErrorForNode(code, node);
    });
  }

  Expression? _getNamedExpression(AstNode node) {
    if (node.parent is FunctionBody) {
      final body = node.parent as FunctionBody;
      if (body.parent is ExpressionFunctionBody) {
        final expressionBody = body.parent as ExpressionFunctionBody;
        if (expressionBody.parent is FunctionExpression) {
          final function = expressionBody.parent as FunctionExpression;
          if (function.parent is NamedExpression) {
            return function.parent as NamedExpression;
          }
        }
      }
    }

    if (node.parent is ReturnStatement) {
      final returnExpression = node.parent as ReturnStatement;
      if (returnExpression.parent is Block) {
        final block = returnExpression.parent as Block;
        if (block.parent is BlockFunctionBody) {
          final functionBody = block.parent as BlockFunctionBody;
          if (functionBody.parent is FunctionExpression) {
            final function = functionBody.parent as FunctionExpression;
            if (function.parent is NamedExpression) {
              return function.parent as NamedExpression;
            }
          }
        }
      }
    }
    return null;
  }

  @override
  List<Fix> getFixes() => [_AvoidWidgetFunctionFix()];
}

class _AvoidWidgetFunctionFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Wrap with Builder widget',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addReplacement(
            range.node(node),
            (builder) {
              builder
                ..write('Builder(')
                ..write('builder: (context) => ' + node.toSource() + ',')
                ..write(')');
            },
          )
          ..format(range.node(node));
      });
    });
  }
}
