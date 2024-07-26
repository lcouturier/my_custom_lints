// ignore_for_file: cascade_invocations, unused_element, unused_import, no_leading_underscores_for_local_identifiers

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class WhenMethodAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!node.sourceRange.covers(target)) return;
      if (!(node.declaredElement?.isAbstract ?? false)) return;
      if (!node.isEquatable) return;

      final whenMethod = node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'when');
      if (whenMethod != null) return;

      final subclasses = _findSubclasses(context, node.declaredElement?.name ?? '');

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Generate when Method',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(node.end - 1, (builder) {
          builder.write(
            node.declaredElement!.isSealed ? _getSealedSwitch(subclasses) : _getAbstractSwitch(subclasses),
          );
        });
        builder.format(range.node(node));
      });
    });
  }

  String _getAbstractSwitch(List<ClassDeclaration> subclasses) {
    final cases = subclasses.map((subclass) {
      final name = subclass.name;
      final fields = subclass.fields;
      final params = fields.map((f) => '${f.name}: var ${f.name}').join(', ');
      return ' case $name($params) : return ${name.lexeme.toLowerCase()}?.call(${fields.map((f) => f.name).join(', ')}) ?? orElse();';
    }).join('\n');

    return '''

  R when<R>({
    ${subclasses.map((s) => 'required R Function(${s.fields.map((f) => f.type.getDisplayString(withNullability: true)).join(', ')})? ${s.name.lexeme.toLowerCase()}').join(',\n    ')},
    required R Function() orElse,
  }) {
    switch (this) {
$cases
      default:
        return orElse();
    }
  }
''';
  }

  String _getSealedSwitch(List<ClassDeclaration> subclasses) {
    final cases = subclasses.map((subclass) {
      final name = subclass.name;
      final fields = subclass.fields;
      final params = fields.map((f) => '${f.name}: var ${f.name}').join(', ');
      return '      $name($params) => ${name.lexeme.toLowerCase()}?.call(${fields.map((f) => f.name).join(', ')}) ?? orElse(),';
    }).join('\n');

    return '''

  R when<R>({
    ${subclasses.map((s) => 'required R Function(${s.fields.map((f) => f.type.getDisplayString(withNullability: true)).join(', ')})? ${s.name.lexeme.toLowerCase()}').join(',\n    ')},
    required R Function() orElse,
  }) {
    return switch (this) {
$cases
    };
  }
''';
  }

  List<ClassDeclaration> _findSubclasses(CustomLintContext context, String baseClassName) {
    final subclasses = <ClassDeclaration>[];
    context.registry.addClassDeclaration((node) {
      final superclass = node.extendsClause?.superclass.name2.lexeme;

      if (superclass == baseClassName) {
        subclasses.add(node);
      }
    });
    return subclasses;
  }
}

extension on ClassDeclaration {
  List<FieldElement> get fields => declaredElement!.fields
      .where((field) => !field.isStatic)
      .where((field) => !field.isSynthetic)
      .toList(growable: false);
}
