import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class EnumPatternMatchingAssist extends DartAssist {
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

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Generate pattern matching',
        priority: 80,
      );

      changeBuilder.addDartFileEdit((builder) {
        final lastItem = node.constants.last;
        if (lastItem.endToken.next case final nextToken?) {
          builder.addSimpleReplacement(range.token(nextToken), ';');
        }

        builder.addInsertion(node.end - 1, (builder) {
          builder.write(_generatePatternMatching(node));
        });
        builder.format(range.node(node));
      });
    });
  }

  String _generatePatternMatching(EnumDeclaration node) {
    final cases = node.constants.map((item) => item.name.lexeme);

    return '''

  R when<R>({
    ${cases.map((s) => 'R Function()? ${s.toLowerCase()}').join(',\n    ')},
    required R Function() orElse,
  }) {
    return switch (this) {
${cases.map((s) => '      ${node.name.lexeme}.$s => ${s.toLowerCase()}?.call() ?? orElse(),').join('\n')}
    };
  }
''';
  }
}
