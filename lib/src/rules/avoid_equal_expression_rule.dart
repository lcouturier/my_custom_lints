// ignore_for_file: lines_longer_than_80_chars

import 'dart:developer';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidEqualExpressionsRule extends DartLintRule {
  static const lintName = 'avoid_equal_expressions';

  const AvoidEqualExpressionsRule()
      : super(
          code: const LintCode(
            name: 'avoid_equal_expressions',
            problemMessage: 'Avoid equal expressions.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      log(node.expression.runtimeType.toString());
      if (node.expression is! BinaryExpression) return;

      final binary = node.expression as BinaryExpression;
      if (binary.leftOperand.toString() != binary.rightOperand.toString()) return;

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addVariableDeclaration((node) {
      if (node.initializer is! BinaryExpression) return;

      final binary = node.initializer! as BinaryExpression;
      if (binary.leftOperand.toString() != binary.rightOperand.toString()) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}

// VariableDeclaration
//     ├── VariableDeclarationList
//     │   ├── VariableDeclaration
//     │   │   ├── Identifier: val1
//     │   │   └── BinaryExpression
//     │   │       ├── Identifier: num
//     │   │       ├── ShiftLeft: <<
//     │   │       └── Identifier: num
//     │   ├── VariableDeclaration
//     │   │   ├── Identifier: val2
//     │   │   └── BinaryExpression
//     │   │       ├── Identifier: num
//     │   │       ├── ShiftRight: >>
//     │   │       └── Identifier: num
//     │   ├── VariableDeclaration
//     │   │   ├── Identifier: val3
//     │   │   └── BinaryExpression
//     │   │       ├── IntegerLiteral: 5
//     │   │       ├── Division: /
//     │   │       └── IntegerLiteral: 5
//     │   └── VariableDeclaration
//     │       ├── Identifier: val4
//     │       └── BinaryExpression
//     │           ├── IntegerLiteral: 10
//     │           ├── Subtraction: -
//     │           └── IntegerLiteral: 10

// IfStatement
// ├── condition: BinaryExpression
// │   ├── leftOperand: BinaryExpression
// │   │   ├── leftOperand: Identifier (num)
// │   │   ├── operator: '=='
// │   │   └── rightOperand: Identifier (anotherNum)
// │   ├── operator: '&&'
// │   └── rightOperand: BinaryExpression
// │       ├── leftOperand: Identifier (num)
// │       ├── operator: '=='
// │       └── rightOperand: Identifier (anotherNum)
// └── thenStatement: ReturnStatement