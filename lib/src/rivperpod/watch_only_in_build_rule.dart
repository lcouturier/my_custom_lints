import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Détecte l'utilisation incorrecte de la méthode `watch()` en dehors des méthodes de build.
///
/// Les méthodes `watch()` de Riverpod ne doivent être utilisées que dans des builders
/// car elles sont conçues pour déclencher des rebuilds lorsque les données changent.
/// Les utiliser ailleurs peut causer des comportements inattendus.
class WatchOnlyInBuildRule extends DartLintRule {
  const WatchOnlyInBuildRule()
      : super(
          code: const LintCode(
            name: 'watch_only_in_build',
            problemMessage: 'La méthode watch() ne devrait être utilisée que dans des méthodes de build',
            correctionMessage: 'Utilisez ref.read() pour un accès ponctuel ou ref.listen() pour réagir aux changements',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name != 'watch') return;

      final target = node.target;
      if (target == null || (target is SimpleIdentifier && target.name != 'ref')) return;

      final containingMethod = _findContainingMethod(node);
      if (containingMethod == null) return;

      if (_isBuilderMethod(containingMethod)) return;

      reporter.atNode(node, code);
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
    final builderNames = [
      'build',
      'buildWidget',
      'buildConsumer',
      'buildWhen',
      'builder',
    ];

    // Vérifie si le nom de la méthode contient "build" ou est dans la liste des builders
    if (builderNames.contains(methodName) || methodName.contains('build')) {
      return true;
    }

    // Vérifie si la méthode renvoie un Widget
    final returnType = method.returnType?.toSource();
    return returnType == 'Widget' || returnType == 'ConsumerWidget';
  }
}
