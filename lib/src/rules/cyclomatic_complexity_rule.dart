import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/base_lint_rule.dart';

/// Limit for the number of linearly independent paths through a program's
/// source code.
///
/// Counts the number of code branches and loop statements within function and
/// method bodies.
///
/// ### Example config:
///
/// This configuration will allow 10 code branchings per function body before
/// triggering a warning.
///
/// ```yaml
/// custom_lint:
///   rules:
///     - cyclomatic_complexity:
///       max_complexity: 10
/// ```
class CyclomaticComplexityRule extends BaseLintRule<CyclomaticComplexityParameters> {
  /// The [LintCode] of this lint rule that represents the error if complexity
  /// reaches maximum value.
  static const lintName = 'cyclomatic_complexity';

  CyclomaticComplexityRule._(super.rule);

  /// Creates a new instance of [CyclomaticComplexityRule]
  /// based on the lint configuration.
  factory CyclomaticComplexityRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: CyclomaticComplexityParameters.fromJson,
      problemMessage:
          (value) =>
              'The maximum allowed complexity of a function is '
              '${value.maxComplexity}. Please decrease it.',
    );

    return CyclomaticComplexityRule._(rule);
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addBlockFunctionBody((node) {
      final visitor = CyclomaticComplexityFlowVisitor();
      node.visitChildren(visitor);

      if (visitor.complexityEntities.length + 1 > config.parameters.maxComplexity) {
        reporter.atNode(node, code);
      }
    });
  }
}

class CyclomaticComplexityParameters {
  final int maxComplexity;

  static const _defaultMaxComplexity = 10;

  const CyclomaticComplexityParameters({required this.maxComplexity});

  factory CyclomaticComplexityParameters.fromJson(Map<String, Object?> map) =>
      CyclomaticComplexityParameters(maxComplexity: map['max_complexity'] as int? ?? _defaultMaxComplexity);
}

class CyclomaticComplexityFlowVisitor extends RecursiveAstVisitor<void> {
  static const _complexityTokenTypes = [
    TokenType.AMPERSAND_AMPERSAND,
    TokenType.BAR_BAR,
    TokenType.QUESTION_PERIOD,
    TokenType.QUESTION_QUESTION,
    TokenType.QUESTION_QUESTION_EQ,
  ];

  final _complexityEntities = <SyntacticEntity>{};

  /// Returns an array of entities that increase cyclomatic complexity.
  Iterable<SyntacticEntity> get complexityEntities => _complexityEntities;

  @override
  void visitAssertStatement(AssertStatement node) {
    _increaseComplexity(node);

    super.visitAssertStatement(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _visitBlock(node.block.leftBracket.next, node.block.rightBracket);

    super.visitBlockFunctionBody(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexity(node);

    super.visitCatchClause(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexity(node);

    super.visitConditionalExpression(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _visitBlock(node.expression.beginToken.previous, node.expression.endToken.next);

    super.visitExpressionFunctionBody(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexity(node);

    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexity(node);

    super.visitIfStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _increaseComplexity(node);

    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _increaseComplexity(node);

    super.visitSwitchDefault(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexity(node);

    super.visitWhileStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _increaseComplexity(node);

    super.visitYieldStatement(node);
  }

  void _visitBlock(Token? firstToken, Token? lastToken) {
    var token = firstToken;
    while (token != lastToken && token != null) {
      if (token.matchesAny(_complexityTokenTypes)) {
        _increaseComplexity(token);
      }

      token = token.next;
    }
  }

  void _increaseComplexity(SyntacticEntity entity) {
    _complexityEntities.add(entity);
  }
}
