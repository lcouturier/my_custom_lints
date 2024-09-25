// ignore_for_file: cascade_invocations, unused_element, unused_import, no_leading_underscores_for_local_identifiers

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/lint_rule_node_registry_extensions.dart';

class CheckStateGetterAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addSubclassesFromClassDeclaration((node, subclasses) {
      if (!node.sourceRange.covers(target)) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Generate getter',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addInsertion(node.end - 1, (builder) {
          builder.write(_generateGetter(subclasses));
        });
        builder.format(range.node(node));
      });
    });
  }

  String _generateGetter(List<ClassDeclaration> subclasses) {
    final getters = subclasses
        .map(
          (e) => (
            propName:
                e.name.lexeme.endsWith('State') ? e.name.lexeme.substring(0, e.name.lexeme.length - 5) : e.name.lexeme,
            name: e.name
          ),
        )
        .map((e) => 'bool get is${e.propName} => this is ${e.name};')
        .join('\n');

    return '''

$getters

''';
  }
}
