import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UnusedFieldsRule extends DartLintRule {
  const UnusedFieldsRule() : super(code: _code);

  static const _code = LintCode(
    name: 'unused_fields',
    problemMessage: 'Le champ "{0}" n\'est pas utilisé dans cette classe.',
    correctionMessage: 'Supprimez le champ non utilisé ou utilisez-le.',
  );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addClassDeclaration((node) {
      _checkUnusedFields(node, reporter);
    });
  }

  void _checkUnusedFields(ClassDeclaration classNode, ErrorReporter reporter) {
    final visitor = _UnusedFieldsVisitor();
    classNode.accept(visitor);

    // Vérifier chaque champ déclaré
    for (final field in visitor.declaredFields) {
      if (!visitor.usedFields.contains(field.name)) {
        // Ignorer les champs privés commençant par '_' si ils sont destinés à un usage externe
        // if (field.name.startsWith('_')) {
        //   // Vous pouvez ajuster cette logique selon vos besoins
        // }

        reporter.atNode(field.node, code, arguments: [field.name]);
      }
    }
  }
}

class _FieldInfo {
  final String name;
  final AstNode node;
  final bool isPrivate;

  _FieldInfo(this.name, this.node) : isPrivate = name.startsWith('_');
}

class _UnusedFieldsVisitor extends RecursiveAstVisitor<void> {
  final List<_FieldInfo> declaredFields = [];
  final Set<String> usedFields = <String>{};

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // Ignorer les champs statiques et constants
    if (node.isStatic || node.fields.isConst || node.fields.isFinal) {
      return;
    }

    for (final variable in node.fields.variables) {
      declaredFields.add(_FieldInfo(variable.name.lexeme, variable));
    }
    super.visitFieldDeclaration(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // Marquer le champ comme utilisé s'il est référencé
    final element = node.staticElement;
    if (element is FieldElement) {
      usedFields.add(element.name);
    } else if (element is PropertyAccessorElement && element.isSetter) {
      // Gérer les setters
      usedFields.add(element.name);
    } else if (element is PropertyAccessorElement && element.isGetter) {
      // Gérer les getters
      usedFields.add(element.name);
    }

    // Marquer aussi les identifiants simples qui correspondent à nos champs
    final fieldName = node.name;
    if (declaredFields.any((field) => field.name == fieldName)) {
      usedFields.add(fieldName);
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    // Gérer les accès aux propriétés comme this.field
    if (node.target is ThisExpression) {
      usedFields.add(node.propertyName.name);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitThisExpression(ThisExpression node) {
    // Gérer les références à this
    super.visitThisExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Si une méthode est appelée sur un champ, marquer le champ comme utilisé
    if (node.target is SimpleIdentifier) {
      final target = node.target! as SimpleIdentifier;
      if (declaredFields.any((field) => field.name == target.name)) {
        usedFields.add(target.name);
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    // Gérer les assignations aux champs
    if (node.leftHandSide is SimpleIdentifier) {
      final identifier = node.leftHandSide as SimpleIdentifier;
      if (declaredFields.any((field) => field.name == identifier.name)) {
        usedFields.add(identifier.name);
      }
    }
    super.visitAssignmentExpression(node);
  }
}
