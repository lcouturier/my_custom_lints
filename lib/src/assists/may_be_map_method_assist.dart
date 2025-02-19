import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';
import 'package:my_custom_lints/src/common/checker.dart';

class MaybeMapMethodAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addSubclassesFromClassDeclaration((node, subclasses) {
      if (!target.intersects(node.sourceRange)) return;

      final mapMethod = node.members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'map');
      if (mapMethod != null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Generate map Method',
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
      return ' case $name() : return ${name.lexeme.toLowerCase()}?.call(this as $name) ?? orElse();';
    }).join('\n');

    return '''

  R map<R>({
    ${subclasses.map((s) => 'required R Function(${s.name.lexeme} value)? ${s.name.lexeme.toLowerCase()}').join(',\n    ')},
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
      return '      $name() => ${name.lexeme.toLowerCase()}?.call(this as $name) ?? orElse(),';
    }).join('\n');

    return '''

  R map<R>({
    ${subclasses.map((s) => 'required R Function(${s.name.lexeme} value)? ${s.name.lexeme.toLowerCase()}').join(',\n    ')},
    required R Function() orElse,
  }) {
    return switch (this) {
$cases
    };
  }
''';
  }
}
