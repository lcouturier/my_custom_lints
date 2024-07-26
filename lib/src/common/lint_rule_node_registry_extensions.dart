import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

extension LintRuleNodeRegistryExtensions on LintRuleNodeRegistry {
  void addClassCubitSuffix(void Function(ClassDeclaration node, String fileName) listener) {
    addClassDeclaration((node) {
      final fileName = node.declaredElement?.source.fullName ?? '';
      final isCubit = const TypeChecker.fromName(
        'Cubit',
        packageName: 'bloc',
      ).isSuperOf(node.declaredElement!);

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

  void addEquatableClassFieldDeclaration(
    void Function({
      required FieldElement fieldElement,
      required ClassDeclaration classNode,
      required List<String> equatablePropsExpressionDetails,
      Expression? propsReturnExpression,
    }) listener,
  ) {
    addFieldDeclaration((fieldNode) {
      final classNode = fieldNode.parent;

      if (classNode is! ClassDeclaration) {
        return;
      }

      final classElement = classNode.declaredElement;
      if (classElement == null) {
        return;
      }

      const typeChecker = TypeChecker.fromName('Equatable', packageName: 'equatable');
      final classType = classElement.thisType;

      if (!typeChecker.isAssignableFromType(classType)) {
        return;
      }

      final propsReturnExpression = classNode.getPropsReturnExpression();
      if (propsReturnExpression == null) return;

      final propsFields = propsReturnExpression.getFieldsFromProps();

      final watchableFields =
          classElement.fields.where((field) => !field.isSynthetic).where((field) => !field.isStatic).toList();

      final fieldElement = watchableFields.firstWhereOrNull(
        (field) => fieldNode.toString().contains('$field ') || fieldNode.toString().contains('$field;'),
      );

      if (fieldElement == null) {
        return;
      }

      listener(
        fieldElement: fieldElement,
        classNode: classNode,
        equatablePropsExpressionDetails: propsFields,
        propsReturnExpression: propsReturnExpression,
      );
    });
  }
}
