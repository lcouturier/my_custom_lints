import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

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

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclarationStatefulWidget((node) {
      final callers = _SetStateCallers(node.name.lexeme);
      node.accept(callers);

      final visitor = _SetStateVisitor(code, reporter, callers.methodsWithSetState, node.name.lexeme);
      node.accept(visitor);
    });
  }
}

class _SetStateVisitor extends RecursiveAstVisitor<void> {
  final LintCode code;
  final ErrorReporter reporter;
  final Set<String> methodsWithSetState;
  final String className;

  MethodDeclaration? currentMethod;
  bool inBuildMethod = false;
  int eventHandlerNestingLevel = 0;

  static const methods = ['initState', 'didUpdateWidget', 'build', 'dispose'];

  _SetStateVisitor(
    this.code,
    this.reporter,
    this.methodsWithSetState,
    this.className,
  );

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final previousMethod = currentMethod;
    final previousInBuildMethod = inBuildMethod;
    currentMethod = node;

    inBuildMethod = node.name.lexeme == 'build';
    super.visitMethodDeclaration(node);

    currentMethod = previousMethod;
    inBuildMethod = previousInBuildMethod;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if ((node.methodName.name == 'setState') && (eventHandlerNestingLevel == 0)) {
      final methodName = currentMethod!.name.lexeme;
      if (methods.any((e) => e == methodName)) {
        reporter.atNode(node, code);
      }
    }

    if ((node.methodName.name != 'setState') && (eventHandlerNestingLevel == 0) && inBuildMethod) {
      final methodName = node.methodName.name;
      final signature = '$className.$methodName';

      if (methodsWithSetState.contains(signature)) {
        reporter.atNode(node, code);
      }
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    final name = node.name.label.name;

    final isEventHandler = name.startsWith('on') && name.length > 2 && name[2].toUpperCase() == name[2];

    if (isEventHandler) {
      eventHandlerNestingLevel++;
      super.visitNamedExpression(node);
      eventHandlerNestingLevel--;
    } else {
      super.visitNamedExpression(node);
    }
  }
}

class _SetStateCallers extends RecursiveAstVisitor<void> {
  final String className;
  final Set<String> methodsWithSetState = {};
  MethodDeclaration? currentMethod;

  _SetStateCallers(this.className);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final previousMethod = currentMethod;
    currentMethod = node;
    super.visitMethodDeclaration(node);
    currentMethod = previousMethod;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setState' && currentMethod != null) {
      final methodName = currentMethod!.name.lexeme;
      methodsWithSetState.add('$className.$methodName');
    }

    super.visitMethodInvocation(node);
  }
}
