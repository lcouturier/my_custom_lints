import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class MaybeWhenMethodAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addSubclassesFromClassDeclaration((node, subclasses) {
      if (!target.intersects(node.sourceRange)) return;

      final whenMethod = node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'when');
      if (whenMethod != null) return;

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
}
