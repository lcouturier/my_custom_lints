import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

extension LintRuleNodeRegistryExtensions on LintRuleNodeRegistry {
  void addGetterDeclaration(void Function(MethodDeclaration node) listener) {
    addMethodDeclaration((MethodDeclaration node) {
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

  void addClassCubitSuffix(void Function(ClassDeclaration node, String fileName) listener) {
    addClassDeclaration((node) {
      final fileName = node.declaredElement?.source.fullName ?? '';
      final isCubit = cubitChecker.isSuperOf(node.declaredElement!);

      if (!isCubit) return;
      if (node.name.lexeme.endsWith('Cubit')) return;

      listener(node, fileName);
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
}
