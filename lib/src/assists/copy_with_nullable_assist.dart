import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/copy_with_utils.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class CopyWithNullableAssist extends DartAssist with CopyWithMixin {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!node.sourceRange.covers(target)) return;
      if (node.declaredElement?.isAbstract ?? true) return;

      if (!_isValidNode(node)) return;

      final copyWithMethod =
          node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'copyWith');
      if (copyWithMethod != null) return;

      final constructor = node.members.whereType<ConstructorDeclaration>().firstWhereOrNull((c) => c.name == null);
      if (constructor == null) return;

      final isAllNamed = constructor.parameters.parameters.every((e) => e.isNamed);
      if (!isAllNamed) return;

      final fields =
          node.declaredElement!.fields.where((field) => !field.isStatic).where((field) => !field.isSynthetic).toList();

      final text = generateCopyWithMethod(node.name.lexeme, fields);
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Add copyWith Method',
        priority: 80,
      );

      // ignore: cascade_invocations
      changeBuilder.addDartFileEdit((builder) {
        builder
          ..addSimpleInsertion(node.endToken.offset, text)
          ..format(node.sourceRange);
      });
    });
  }

  bool _isValidNode(ClassDeclaration node) {
    final predicate = [
      (ClassDeclaration node) => node.isEquatable,
      (ClassDeclaration node) => node.isImmutable,
    ];

    return predicate.any((p) => p(node));
  }
}
