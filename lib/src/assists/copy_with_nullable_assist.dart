import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class CopyWithNullableAssist extends DartAssist {
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

      final text = _generateCopyWithMethod(node.name.lexeme, fields);
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
      () => node.isEquatable,
      () => node.isImmutable,
    ];

    return predicate.any((p) => p());
  }

  // FIX(LACO): fix constructors parameters unnamed
  String _generateCopyWithMethod(String className, List<FieldElement> fields) {
    final fieldParams =
        fields.map((f) => '${f.type}${isNullableType(f.type) ? 'Function()?' : '?'} ${f.name}').join(', ');
    final fieldAssignments = fields.map((f) {
      if (!isNullableType(f.type)) {
        return '${f.name}: ${f.name} ?? this.${f.name},';
      } else {
        return '${f.name}: ${f.name} != null ? ${f.name}() : this.${f.name},';
      }
    }).join('\n    ');

    return '\n    '
        '''
  $className copyWith({
    $fieldParams
  }) {
    return $className(
      $fieldAssignments
    );
  }
''';
  }
}
