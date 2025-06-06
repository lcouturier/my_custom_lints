import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Détecte l'utilisation incorrecte de la méthode `read()` dans les méthodes de build.
///
/// Les méthodes `read()` de Riverpod ne devraient pas être utilisées dans des builders
/// car elles ne déclenchent pas de rebuilds lorsque les données changent.
/// Utilisez `watch()` à la place pour garantir que l'UI se met à jour quand les données changent.
class ReadNotInBuildRule extends DartLintRule {
  const ReadNotInBuildRule()
    : super(
        code: const LintCode(
          name: 'read_not_in_build',
          problemMessage: 'La méthode read() ne devrait pas être utilisée dans des méthodes de build',
          correctionMessage:
              'Utilisez ref.watch() pour observer les changements et reconstruire le widget automatiquement',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'read') return;

      final target = node.target;
      if (target == null || (target is SimpleIdentifier && target.name != 'ref')) return;

      final containingMethod = _findContainingMethod(node);
      if (containingMethod == null) return;

      if (_isBuilderMethod(containingMethod)) {
        if (!_isInEventHandler(node)) {
          reporter.atNode(node, code);
        }
      }
    });
  }

  /// Trouve la méthode contenant le nœud donné
  MethodDeclaration? _findContainingMethod(AstNode node) {
    AstNode? current = node;
    while (current != null) {
      if (current is MethodDeclaration) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  /// Vérifie si la méthode est un builder
  bool _isBuilderMethod(MethodDeclaration method) {
    final methodName = method.name.lexeme;

    // Liste des noms de méthodes qui sont considérées comme des builders
    final builderNames = ['build', 'buildWidget', 'buildConsumer', 'buildWhen', 'builder'];

    // Vérifie si le nom de la méthode contient "build" ou est dans la liste des builders
    if (builderNames.contains(methodName) || methodName.contains('build')) {
      return true;
    }

    // Vérifie si la méthode renvoie un Widget
    final returnType = method.returnType?.toSource();
    return returnType == 'Widget' || returnType == 'ConsumerWidget';
  }

  /// Vérifie si le nœud est dans un gestionnaire d'événements (comme onPressed)
  bool _isInEventHandler(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      // Vérifie si le nœud est dans une fonction anonyme qui est passée à un paramètre
      // comme onPressed, onTap, etc.
      if (current is NamedExpression) {
        final paramName = current.name.label.name;
        final eventHandlerParams = ['onPressed', 'onTap', 'onChanged', 'onSubmitted', 'onComplete'];
        if (eventHandlerParams.contains(paramName)) {
          return true;
        }
      }
      current = current.parent;
    }
    return false;
  }
}
