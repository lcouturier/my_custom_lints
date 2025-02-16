import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

class EnumPredicateGettersAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addEnumDeclaration((node) {
      if (!node.sourceRange.covers(target)) return;
      if (node.constants.any((e) => e.name.lexeme == 'DEFAULT')) return;

      final getters = node.members
          .whereType<MethodDeclaration>()
          .where((e) => e.isGetter)
          .where((e) => e.name.lexeme.startsWith('is'))
          .map((e) => e.name.lexeme.substring(2).toLowerCase())
          .toList();

      final predicates = node.constants.map((e) => e.name.lexeme).toList();
      final items = predicates.except(getters);
      if (items.isEmpty) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Generate predicate getters',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final lastItem = node.constants.last;

        if (lastItem.endToken.next case final nextToken?) {
          builder.addSimpleReplacement(range.token(nextToken), ';');
        }

        builder.addInsertion(node.end - 1, (builder) {
          builder.write(_generateGetter(items.toList()));
        });
        builder.format(range.node(node));
      });
    });
  }

  String _generateGetter(List<String> items) {
    final getters = items.map((e) => 'bool get is${e.firstUpper} => this == $e;').join('\n');

    return '''

$getters

''';
  }
}
