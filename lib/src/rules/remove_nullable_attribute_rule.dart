// ignore_for_file: unused_import, unused_element

import 'dart:async';
import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

// ignore: must_be_immutable
class RemoveNullableAttributeRule extends DartLintRule {
  Map<String, List<MethodInvocation>> methodInvocations = <String, List<MethodInvocation>>{};

  RemoveNullableAttributeRule()
    : super(
        code: const LintCode(
          name: 'remove_nullable_attribute',
          problemMessage: 'remove nullable attribute from read method invocation',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    //final completer = Completer<void>();

    // context.registry.addMethodInvocation((node) {
    //   final element = node.methodName.staticElement;

    //   if (element != null) {
    //     final name = element.name;
    //     methodInvocations.putIfAbsent(name!, () => []).add(node);
    //   }
    // });

    context.registry.addCompilationUnit((unit) {
      // if (!completer.isCompleted) {
      //   completer.complete();
      // }
      // completer.future.then((_) {
      unit
        ..visitChildren(
          _InvocationVisitor(onAdd: (name, node) => methodInvocations.putIfAbsent(name!, () => []).add(node)),
        )
        ..visitChildren(_Verifier(methodInvocations, reporter));
    });
    // });
  }
}

class _InvocationVisitor extends RecursiveAstVisitor<void> {
  final void Function(String?, MethodInvocation) onAdd;

  _InvocationVisitor({required this.onAdd});
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.staticElement;

    if (element != null) {
      final name = element.name;
      onAdd(name, node);
    }
  }
}

class _Verifier extends RecursiveAstVisitor<void> {
  final Map<String, List<MethodInvocation>> methodInvocations;
  final ErrorReporter reporter;

  _Verifier(this.methodInvocations, this.reporter);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final methodElement = node.declaredElement;
    if (methodElement == null) return;
    if (methodElement.name != 'addCodePromo') return;

    final hasNullableStringParam = methodElement.parameters.any(
      (param) => param.type.isDartCoreString && param.type.nullabilitySuffix == NullabilitySuffix.question,
    );
    if (!hasNullableStringParam) return;

    final invocations = methodInvocations[methodElement.name] ?? [];
    final hasNullArgument = invocations.any((invocation) {
      final args = invocation.argumentList.arguments;
      return args.any((arg) => arg is NullLiteral);
    });

    if (hasNullArgument) return;

    reporter.reportErrorForNode(
      const LintCode(
        name: 'remove_nullable_attribute',
        problemMessage: 'remove nullable attribute from read method invocation',
        errorSeverity: ErrorSeverity.WARNING,
      ),
      node,
    );
  }
}
