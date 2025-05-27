// ignore_for_file: avoid_single_cascade_in_expression_statements, unused_import

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';

import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/copy_with_utils.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class AvoidIncompleteCopyWithRule extends DartLintRule {
  const AvoidIncompleteCopyWithRule()
      : super(
          code: const LintCode(
            name: 'avoid_incomplete_copy_with',
            problemMessage: 'Ensure all fields are included in copyWith method.',
            correctionMessage: '',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      final (found, copyWithMethod) =
          node.members.whereType<MethodDeclaration>().firstWhereOrNot((method) => method.name.lexeme == 'copyWith');
      if (!found) return;

      final fields = node.members
          .whereType<FieldDeclaration>()
          .map((e) => e.fields.variables.map((variable) => variable.name.lexeme).toList())
          .expand((f) => f)
          .toSet();
      if (fields.isEmpty) return;

      final body = copyWithMethod!.body.expression;
      if (body == null) return;

      if (body is! InstanceCreationExpression) return;
      if (body.constructorName.type.name2.lexeme != node.declaredElement?.name) return;
      if (body.argumentList.arguments.length == fields.length) return;

      reporter.reportErrorForNode(code, copyWithMethod);
    });
  }
}

// ignore: unused_element
class _AvoidIncompleteCopyWithFix extends DartFix with CopyWithMixin {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!analysisError.sourceRange.covers(node.sourceRange)) return;

      final parent = node.parent;
      if (parent is! ClassDeclaration) return;

      final constructor = parent.members.whereType<ConstructorDeclaration>().firstWhereOrNull((c) => c.name == null);
      if (constructor == null) return;

      final isAllNamed = constructor.parameters.parameters.every((e) => e.isNamed);
      if (!isAllNamed) return;

      final fields = parent.declaredElement!.fields
          .where((field) => !field.isStatic)
          .where((field) => !field.isSynthetic)
          .toList();

      final isAllFinal = fields.every((e) => e.isFinal);
      if (!isAllFinal) return;

      final text = generateCopyWithMethod(parent.name.lexeme, fields, isAllNamed: isAllNamed);
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Fix copyWith Method',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addReplacement(range.node(node), (builder) {
            builder.write(text);
          })
          ..format(range.node(node));
      });
    });
  }
}
