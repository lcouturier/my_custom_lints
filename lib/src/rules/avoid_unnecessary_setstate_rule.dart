import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidUnnecessarySetStateRule extends DartLintRule {
  const AvoidUnnecessarySetStateRule()
      : super(
          code: const LintCode(
            name: 'avoid_unnecessary_setstate',
            problemMessage:
                "Warns when setState is called inside initState, didUpdateWidget or build methods and when it's called from a sync method that is called inside those methods.",
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const methods = ['initState', 'didUpdateWidget', 'build'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!methods.contains(node.name.lexeme)) return;
      final body = node.body;
      if (body is! BlockFunctionBody) return;

      final visitor = _Visitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidUnnecessarySetStateFix()];
}

class _Visitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  Iterable<AstNode> get nodes => _nodes;
  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    if (node.methodName.name == 'setState') {
      _nodes.add(node);
    }
  }
}

class _AvoidUnnecessarySetStateFix extends DartFix {
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Remove unnecessary setState',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addDeletion(range.startEnd(node.beginToken, node.endToken.next!));
      });
    });
  }
}
