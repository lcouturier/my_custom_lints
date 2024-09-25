import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/copy_with_utils.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class CopyWithMethodFieldCheckRule extends DartLintRule {
  const CopyWithMethodFieldCheckRule()
      : super(
          code: const LintCode(
            name: 'copy_with_method_field_check',
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
    context.registry.addClassDeclaration((node) {
      final fields = node.members
          .whereType<FieldDeclaration>()
          .map((e) => e.fields.variables.map((variable) => variable.name.lexeme).toList())
          .expand((f) => f)
          .toSet();
      if (fields.isEmpty) return;

      final copyWithMethod =
          node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'copyWith');
      if (copyWithMethod == null) return;

      final parameters = copyWithMethod.parameters?.parameters.map((e) => e.name?.lexeme ?? '').toSet();
      if (parameters?.isEmpty ?? true) return;

      final missingFields = fields.difference(parameters!);
      if (missingFields.isEmpty) return;

      reporter.reportErrorForNode(code, copyWithMethod, [], [], node);
    });
  }

  @override
  List<Fix> getFixes() => [_CopyWithMethodFieldCheckFix()];
}

class _CopyWithMethodFieldCheckFix extends DartFix with CopyWithMixin {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addClassDeclaration((_) {
      final node = analysisError.data! as ClassDeclaration;

      final copyWithMethod =
          node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'copyWith');
      if (copyWithMethod == null) return;

      final constructor = node.members.whereType<ConstructorDeclaration>().firstWhereOrNull((c) => c.name == null);
      if (constructor == null) return;

      final isAllNamed = constructor.parameters.parameters.every((e) => e.isNamed);
      if (!isAllNamed) return;

      final fields =
          node.declaredElement!.fields.where((field) => !field.isStatic).where((field) => !field.isSynthetic).toList();

      final text = generateCopyWithMethod(node.name.lexeme, fields);

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Fix copyWith Method',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addSimpleReplacement(copyWithMethod.sourceRange, text)
          ..format(node.sourceRange);
      });
    });
  }
}
