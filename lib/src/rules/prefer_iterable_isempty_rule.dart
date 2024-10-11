import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferIterableIsEmptyRule extends BaseLintRule<PreferIterableIsAnyParameters> {
  static const lintName = 'prefer_iterable_isempty';

  PreferIterableIsEmptyRule._(super.rule);

  factory PreferIterableIsEmptyRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferIterableIsAnyParameters.fromJson,
      problemMessage: (value) =>
          'Using Iterable.length == 0 is more verbose than Iterable.isEmpty. Consider using Iterable.isEmpty for better readability.',
    );

    return PreferIterableIsEmptyRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = _Visitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_ReplaceWithIterablIsEmpty()];
}

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    final targetType = node.leftOperand.staticType;
    if (targetType == null || !listChecker.isAssignableFromType(targetType)) {
      return;
    }

    if (node.operator.type != TokenType.EQ_EQ) return;
    if (!node.leftOperand.toString().contains('length')) return;
    if (node.rightOperand is! IntegerLiteral) return;
    if (node.rightOperand.toString() != '0') return;

    _nodes.add(node);
  }
}

class _ReplaceWithIterablIsEmpty extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addBinaryExpression((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final value = (node.rightOperand as IntegerLiteral).value.toString();

      final useDirect = (node.operator.type == TokenType.EQ_EQ && value == '0') ||
          (node.operator.type == TokenType.BANG_EQ && value == '0');

      final changeBuilder = reporter.createChangeBuilder(
        message: useDirect ? 'Just use isEmpty' : 'Just use isNotEmpty',
        priority: 80,
      );

      final range = node.sourceRange;
      changeBuilder.addDartFileEdit((builder) {
        final replacement = node.leftOperand.toString().replaceFirst('.length', useDirect ? '.isEmpty' : '.isNotEmpty');
        builder.addSimpleReplacement(
          range,
          replacement,
        );
      });
    });
  }
}

class PreferIterableIsAnyParameters {
  const PreferIterableIsAnyParameters();

  // ignore: avoid_unused_constructor_parameters
  factory PreferIterableIsAnyParameters.fromJson(Map<String, Object?> map) {
    return const PreferIterableIsAnyParameters();
  }
}
