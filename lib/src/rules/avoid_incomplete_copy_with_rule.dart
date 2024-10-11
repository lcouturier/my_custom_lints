// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (node.name.lexeme != 'copyWith') return;

      final parent = node.parent;
      if (parent is! ClassDeclaration) return;

      final fields = parent.members
          .whereType<FieldDeclaration>()
          .map((e) => e.fields.variables.map((variable) => variable.name.lexeme).toList())
          .expand((f) => f)
          .toSet();
      if (fields.isEmpty) return;

      final copyWithMethod =
          parent.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'copyWith');
      if (copyWithMethod == null) return;

      final parameters = copyWithMethod.parameters?.parameters.map((e) => e.name?.lexeme ?? '').toSet();
      if (parameters?.isEmpty ?? true) return;

      final missingFields = fields.difference(parameters!);
      if (missingFields.isEmpty) return;

      log('parameters : $parameters');
      log('Found missing fields : $missingFields');

      reporter.reportErrorForNode(
          code,
          node,
          [missingFields.join(', ')],
          [],
          parent.declaredElement!.fields
              .where((field) => !field.isStatic)
              .where((field) => !field.isSynthetic)
              .toSet());
    });
  }

  @override
  List<Fix> getFixes() => [_AvoidIncompleteCopyWithFix()];
}

class _AvoidIncompleteCopyWithFix extends DartFix {
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

      final fields = analysisError.data! as Set<FieldElement>;

      final fieldParams =
          fields.map((f) => '${f.type}${isNullableType(f.type) ? 'Function()?' : '?'} ${f.name}').join(', ');
      final fieldAssignments = fields.map((f) {
        if (!isNullableType(f.type)) {
          return '${f.name}: ${f.name} ?? this.${f.name},';
        } else {
          return '${f.name}: ${f.name} != null ? ${f.name}() : this.${f.name},';
        }
      }).join('\n    ');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Fix copyWith Method',
        priority: 80,
      );

      final parent = node.parent;
      final className = (parent as ClassDeclaration).name.lexeme;

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addReplacement(range.node(node), (builder) {
            builder
              ..writeln('$className ${node.name}({$fieldParams})')
              ..writeln('{ ')
              ..write(' return $className(')
              ..write(fieldAssignments)
              ..writeln(' );')
              ..writeln('}');
          })
          ..format(range.node(node));
      });
    });
  }
}
