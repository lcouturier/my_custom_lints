import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

enum SpreadParentType { List, SetOrMap }

extension LintRuleNodeRegistryExtensions on LintRuleNodeRegistry {
  void addGetterDeclaration(void Function(MethodDeclaration node) listener) {
    addMethodDeclaration((node) {
      if (node.isGetter) {
        listener(node);
      }
    });
  }

  List<ClassDeclaration> _findSubclasses(String baseClassName) {
    final subclasses = <ClassDeclaration>[];
    addClassDeclaration((node) {
      if (node.extendsClause?.superclass.name2.lexeme == baseClassName) {
        subclasses.add(node);
      }
    });
    return subclasses;
  }

  void addSubclassesFromClassDeclaration(
    void Function(ClassDeclaration node, List<ClassDeclaration> subclasses) listener,
  ) {
    addClassDeclaration((node) {
      final element = node.declaredElement;
      if (element == null || !element.isAbstract || !node.isEquatable) return;

      final subclasses = _findSubclasses(node.declaredElement?.name ?? '');
      listener(node, subclasses);
    });
  }

  void addCubitClassDeclaration(void Function(ClassDeclaration node) listener) {
    addClassDeclaration((node) {
      final isCubit = cubitChecker.isSuperOf(node.declaredElement!);
      if (!isCubit) return;

      listener(node);
    });
  }

  void addMethodeDeclarationCubit(void Function(MethodDeclaration node) listener) {
    addMethodDeclaration((node) {
      final parent = node.parent;
      if (parent is! ClassDeclaration) return;

      final isCubit = cubitChecker.isSuperOf(parent.declaredElement!);
      if (!isCubit) return;

      listener(node);
    });
  }

  void addClassDeclarationBlocAndCubit(void Function(ClassDeclaration node) listener) {
    addClassDeclaration((node) {
      if (node.extendsClause == null) return;
      if ((!node.isCubit) && (!node.isBloc)) return;

      listener(node);
    });
  }

  void addVoidCallback(void Function(GenericFunctionType node) listener) {
    addGenericFunctionType((node) {
      final returnType = node.returnType?.type;
      if (returnType is! VoidType) return;

      final parameters = node.parameters.parameters;
      if (parameters.isNotEmpty) return;

      final typeParameters = node.typeParameters?.typeParameters;
      if (typeParameters != null) return;

      listener(node);
    });
  }

  void addReturnType(void Function(TypeAnnotation? node, AstNode parent) listener) {
    addGenericFunctionType((node) {
      listener(node.returnType, node);
    });

    addFunctionTypedFormalParameter((node) {
      listener(node.returnType, node);
    });

    addMethodDeclaration((node) {
      listener(node.returnType, node);
    });

    addFunctionDeclaration((node) {
      listener(node.returnType, node);
    });
  }

  void addEquatableProps(
      void Function(ListLiteral node, Set<String> watchableFields, Set<String> missingFields, bool hasSuperProps)
          listener) {
    addClassDeclaration((node) {
      if (!node.isEquatable) return;

      final props = node.propsReturnExpression();
      if (!props.found) return;

      final propsFields = props.expression!.getFieldsFromProps();
      if (propsFields.isEmpty) return;

      final watchableFields = node.members
          .whereType<FieldDeclaration>()
          .map((e) => e.fields.variables.map((variable) => variable.name.lexeme).toList())
          .expand((e) => e)
          .toSet();

      final missingFields = watchableFields.toSet().difference(propsFields.toSet()).toSet();
      if (missingFields.isEmpty) return;

      final values = props.expression! as ListLiteral;
      final hasSuperProps = values.elements.any((element) => element.toString().contains('super.props'));

      listener(values, watchableFields, missingFields, hasSuperProps);
    });
  }

  void addNullAwareExpression(void Function(BinaryExpression node, bool isCheckingTrue) listener) {
    addBinaryExpression((node) {
      if (!([
        () => (node.leftOperand is PropertyAccess),
        () => (node.leftOperand is SimpleIdentifier),
      ]).any((e) => e())) return;

      if ((node.operator.type != TokenType.EQ_EQ) && (node.operator.type != TokenType.BANG_EQ)) return;
      if (node.rightOperand is! BooleanLiteral) return;
      final leftOperand = node.leftOperand;
      if (leftOperand.staticType != null && !leftOperand.staticType.isNullable) return;

      final isCheckingTrue = (node.rightOperand as BooleanLiteral).value;
      listener(node, isCheckingTrue);
    });
  }

  void addLiteralSpreadItem(void Function(AstNode node, String name) listener) {
    addListLiteral((node) {
      for (var element in node.elements.whereType<SpreadElement>().where((e) => e.expression is BinaryExpression)) {
        final binary = element.expression as BinaryExpression;
        if (binary.rightOperand is TypedLiteral) {
          if (binary.operator.type == TokenType.QUESTION_QUESTION) {
            final id = binary.leftOperand as SimpleIdentifier;
            listener(element, id.name);
          }
        }
      }

      for (var element
          in node.elements.whereType<SpreadElement>().where((e) => e.expression is ConditionalExpression)) {
        final conditional = element.expression as ConditionalExpression;
        if (conditional.condition is BinaryExpression) {
          final binary = conditional.condition as BinaryExpression;

          if ((binary.operator.type == TokenType.BANG_EQ) && (binary.rightOperand is NullLiteral)) {
            final id = binary.leftOperand as SimpleIdentifier;
            listener(element, id.name);
          }
        }
      }

      for (var element in node.elements.whereType<IfElement>()) {
        if ((element.expression is BinaryExpression) && (element.thenElement is SpreadElement)) {
          final binary = element.expression as BinaryExpression;
          final left = binary.leftOperand as SimpleIdentifier;
          if ((element.thenElement as SpreadElement).expression is! SimpleIdentifier) return;
          final then = ((element.thenElement as SpreadElement).expression as SimpleIdentifier);
          if (left.name != then.name) return;
          if ((binary.operator.type == TokenType.BANG_EQ) && (binary.rightOperand is NullLiteral)) {
            listener(element, left.name);
          }
        }
      }
    });
  }

  void addMethodDeclarationWithParameters(void Function(MethodDeclaration node) listener) {
    addMethodDeclaration((node) {
      if (node.metadata.any((e) => e.name.name.startsWith('Deprecated'))) return;
      if (node.parameters?.parameters.isEmpty ?? true) return;
    });
  }

  /// Finds all spread operators (e.g. `...`) that are not inside of a
  /// collection literal (e.g. `[1, 2, ...rest]`) and have only one item
  /// following the spread operator.
  void addUselessSpreadOperator(
      void Function(
        TypedLiteral node,
        NodeList<CollectionElement> elements,
      ) listener) {
    addTypedLiteral((node) {
      if (node.beginToken.previous?.type != TokenType.PERIOD_PERIOD_PERIOD) return;

      final elements = switch (node) {
        ListLiteral() => node.elements,
        SetOrMapLiteral() => node.elements,
      };

      bool hasFewItems = elements.length > 1;
      if (hasFewItems) return;

      listener(node, elements);
    });
  }

  void addIfStatementNullAssertion(
      void Function(BinaryExpression condition, Identifier node, NodeList<Statement> statements) listener) {
    addIfStatement((node) {
      final condition = node.expression;

      if (condition is! BinaryExpression) return;
      if (condition.operator.type != TokenType.BANG_EQ) return;
      if (condition.leftOperand is! Identifier) return;
      if (condition.rightOperand is! NullLiteral) return;

      final variable = condition.leftOperand as Identifier;
      final thenBlock = node.thenStatement;
      if (thenBlock is! Block) return;

      listener(condition, variable, thenBlock.statements);
    });
  }
}
