import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/names.dart';

/// Rule which forbids building widgets with getters/methods/functions,
/// unless it's a Provider.
class AvoidWidgetFunctionRule extends DartLintRule {
  static const problem = 'Returning a widget from a function or method '
      'is an anti-pattern.';
  static const correction = 'Unless method is overridden, '
      'consider extracting your widget to a separate class.';

  const AvoidWidgetFunctionRule()
      : super(
          code: const LintCode(
            name: RuleNames.avoidWidgetFunction,
            problemMessage: problem,
            correctionMessage: correction,
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry
      ..addFunctionDeclaration((node) {
        final isOverridden = node.declaredElement?.hasOverride ?? false;
        if (!isOverridden) {
          _checkReturnType(reporter, node.returnType);
        }
      })
      ..addMethodDeclaration((node) {
        final isOverridden = node.declaredElement?.hasOverride ?? false;
        if (!isOverridden) {
          _checkReturnType(reporter, node.returnType);
        }
      });
  }

  void _checkReturnType(ErrorReporter reporter, TypeAnnotation? returnType) {
    final type = returnType?.type;
    if (returnType != null && type != null && _hasWidgetType(type)) {
      reporter.reportErrorForNode(code, returnType);
    }
  }

  bool _hasWidgetType(DartType type) {
    final isWidget = _isWidgetOrSubclass(type);

    final isProvider = _isMultiProviderOrSubclass(type) || _isProviderOrSubclass(type);

    return isWidget && !isProvider;
  }

  bool _isWidgetOrSubclass(DartType? type) => _isClassOrSubclass(type, _isWidget);

  bool _isWidget(DartType? type) => type?.getDisplayString(withNullability: false) == 'Widget';

  bool _isMultiProviderOrSubclass(DartType? type) => _isClassOrSubclass(type, _isMultiProvider);

  bool _isMultiProvider(DartType? type) => type?.getDisplayString(withNullability: false) == 'MultiProvider';

  bool _isProviderOrSubclass(DartType? type) => _isClassOrSubclass(type, _isInheritedProvider);

  bool _isInheritedProvider(DartType? type) =>
      type?.getDisplayString(withNullability: false).startsWith('InheritedProvider') ?? false;

  bool _isClassOrSubclass(DartType? type, bool Function(DartType?) isClass) =>
      isClass(type) || (type is InterfaceType && type.allSupertypes.any(isClass));
}
