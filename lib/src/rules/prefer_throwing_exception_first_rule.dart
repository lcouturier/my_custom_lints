import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class PreferThrowingExceptionFirstRule extends DartLintRule {
  const PreferThrowingExceptionFirstRule()
    : super(
        code: const LintCode(
          name: 'prefer_throwing_exception_first',
          problemMessage: 'Prefer throwing exception first.',
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addIfStatement((node) {
      if (node.expression is! BinaryExpression) return;

      bool isExpression =
          (node.elseStatement is ExpressionStatement) &&
          (node.elseStatement is ExpressionStatement) &&
          (node.elseStatement! as ExpressionStatement).expression is ThrowExpression;
      if (isExpression) {
        reporter.reportErrorForNode(code, node);
      }

      if (node.thenStatement is! Block) return;
      if (node.elseStatement is! Block) return;

      final thenStatement = (node.thenStatement as Block).statements.last;
      final elseStatement = (node.elseStatement! as Block).statements.last;

      if (thenStatement is! ReturnStatement) return;
      if (elseStatement is! ExpressionStatement) return;
      if (elseStatement.expression is! ThrowExpression) return;

      reporter.reportErrorForNode(code, node);
    });
  }

  @override
  List<Fix> getFixes() => [_PreferThrowingExceptionFirstFix()];
}

class _PreferThrowingExceptionFirstFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addIfStatement((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(message: 'Move throwing exception first.', priority: 80);

      if (node.expression is! BinaryExpression) return;

      final binary = node.expression as BinaryExpression;

      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addReplacement(range.node(node), (builder) {
            builder
              ..write('if (')
              ..write(binary.invert)
              ..write(')')
              ..write(node.elseStatement!.toSource())
              ..write('');
            if (node.thenStatement is Block) {
              for (var e in (node.thenStatement as Block).statements) {
                builder.write(e.toSource());
              }
            } else {
              builder.write(node.thenStatement.toSource());
            }
          })
          ..format(node.sourceRange);
      });
    });
  }
}

extension on BinaryExpression {
  String get invert {
    return '${leftOperand.toSource()} ${operator.type.invert.$1.lexeme} ${rightOperand.toSource()}';
  }
}
