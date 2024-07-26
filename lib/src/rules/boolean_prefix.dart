// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class BooleanPrefixesOptions {
  const BooleanPrefixesOptions({
    List<String>? validPrefixes,
  }) : _validPrefixes = validPrefixes;

  static const defaultValidPrefixes = [
    'is',
    'are',
    'was',
    'were',
    'has',
    'have',
    'had',
    'can',
    'should',
    'will',
    'do',
    'does',
    'did',
  ];

  final List<String>? _validPrefixes;

  List<String> get validPrefixes => [
        ...defaultValidPrefixes,
        ...?_validPrefixes,
      ];
}

class BooleanPrefixes extends DartLintRule {
  static const ruleName = 'boolean_prefixes';

  const BooleanPrefixes()
      : super(
          code: const LintCode(
            name: ruleName,
            problemMessage: 'Invalid prefix on boolean variable.',
            correctionMessage: 'Invalid prefix on boolean variable.',
            errorSeverity: ErrorSeverity.ERROR,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBooleanLiteral((node) {
      final parent = node.parent;
      if (parent is! VariableDeclaration) return;

      final name = parent.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        parent.name,
        [
          'Boolean variable',
          'variable',
        ],
      );
    });

    context.registry.addMethodDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      if (node.isOperator) return;

      final element = node.declaredElement;
      if (element == null || element.hasOverride) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      final parameter = node.parameters;
      switch (parameter) {
        case null:
          reporter.reportErrorForToken(
            code,
            node.name,
            [
              'Getter that returns a boolean',
              'getter',
            ],
          );
        case _:
          reporter.reportErrorForToken(
            code,
            node.name,
            [
              'Method that returns a boolean',
              'method',
            ],
          );
      }
    });

    context.registry.addFunctionDeclaration((node) {
      final returnType = node.returnType?.type;
      if (returnType == null || !returnType.isDartCoreBool) return;

      final name = node.name.lexeme;
      if (isNameValid(name)) return;

      reporter.reportErrorForToken(
        code,
        node.name,
        [
          'Function that returns a boolean',
          'function',
        ],
      );
    });
  }

  bool isNameValid(String name) {
    const defaultValidPrefixes = [
      'is',
      'are',
      'was',
      'were',
      'has',
      'have',
      'had',
      'can',
      'should',
      'will',
      'do',
      'does',
      'did',
    ];

    final nameWithoutUnderscore = name.startsWith('_') ? name.substring(1) : name;

    print(nameWithoutUnderscore);

    return defaultValidPrefixes.any(nameWithoutUnderscore.startsWith);
  }
}
