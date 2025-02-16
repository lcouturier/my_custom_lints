import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

bool isIterableOrSubclassCore(DartType? type) => _checkSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

bool isListOrSubclass(DartType? type) => _checkSelfOrSupertypes(type, (t) => t?.isDartCoreList ?? false);

// ignore: unused-code
bool isMapOrSubclass(DartType? type) => _checkSelfOrSupertypes(type, (t) => t?.isDartCoreMap ?? false);

bool isNullableType(DartType? type) => type?.nullabilitySuffix == NullabilitySuffix.question;

DartType? getSupertypeIterable(DartType? type) => _getSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

DartType? getSupertypeList(DartType? type) => _getSelfOrSupertypes(type, (t) => t?.isDartCoreList ?? false);

DartType? getSupertypeSet(DartType? type) => _getSelfOrSupertypes(type, (t) => t?.isDartCoreSet ?? false);

DartType? getSupertypeMap(DartType? type) => _getSelfOrSupertypes(type, (t) => t?.isDartCoreMap ?? false);

bool _checkSelfOrSupertypes(
  DartType? type,
  bool Function(DartType?) predicate,
) =>
    predicate(type) || (type is InterfaceType && type.allSupertypes.any(predicate));

DartType? _getSelfOrSupertypes(
  DartType? type,
  bool Function(DartType?) predicate,
) {
  if (predicate(type)) {
    return type;
  }
  if (type is InterfaceType) {
    return type.allSupertypes.firstWhereOrNull(predicate);
  }

  return null;
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  (bool found, T?) firstWhereOrNot(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return (true, element);
    }
    return (false, null);
  }

  R firstWhereOrElse<R>(bool Function(T element) test, R Function(T) selector, R Function() orElse) {
    for (final element in this) {
      if (test(element)) return selector(element);
    }
    return orElse();
  }
}

const stringChecker = TypeChecker.fromUrl('dart:core#String');
const listChecker = TypeChecker.fromUrl('dart:core#List');
const iterableChecker = TypeChecker.fromUrl('dart:core#Iterable');
const equatableChecker = TypeChecker.fromName('Equatable', packageName: 'equatable');
const cubitChecker = TypeChecker.fromName('Cubit', packageName: 'bloc');
const blocChecker = TypeChecker.fromName('Bloc', packageName: 'bloc');
const widgetChecker = TypeChecker.fromName('Widget', packageName: 'flutter');
const stateChecker = TypeChecker.fromName('State', packageName: 'flutter');
const statelessChecker = TypeChecker.fromName('StatelessWidget', packageName: 'flutter');

class RecursiveSimpleIdentifierVisitor extends RecursiveAstVisitor<void> {
  const RecursiveSimpleIdentifierVisitor({
    required this.onVisitSimpleIdentifier,
  });

  final void Function(SimpleIdentifier node) onVisitSimpleIdentifier;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    onVisitSimpleIdentifier(node);
    node.visitChildren(this);
  }
}
