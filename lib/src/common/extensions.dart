// Extension to check if a class is an Equatable class

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/checker.dart';

extension DartTypeExtensions on DartType {
  bool get isNullableList {
    final predicates = [
      () => this is InterfaceType,
      () => element?.name == 'List',
      () => nullabilitySuffix == NullabilitySuffix.question,
    ];

    return predicates.every((e) => e());
  }

  bool _isSubtypeOfType(String typeName) {
    return element?.displayName == typeName ||
        ((this is InterfaceType) && (this as InterfaceType).allSupertypes.any((e) => e.element.name == typeName));
  }

  bool Function(String) get isSubtypeOfType => _isSubtypeOfType.cache();
}

extension FunctionCacheExtensions<F, R> on R Function(F) {
  R Function(F) cache() {
    final cache = <F, R>{};
    return (key) => cache[key] ??= this(key);
  }
}

extension RecordTypeExtensions on RecordType {
  bool get isMixed => positionalFields.isNotEmpty && namedFields.isNotEmpty;
}

extension DartTypeNullableExtensions on DartType? {
  bool get isIterableOrSubclass => isIterableOrSubclassCore(this);
  bool get isNullable => isNullableType(this);
  bool get isWidget => this?.getDisplayString(withNullability: false) == 'Widget';

  bool get isCallbackType {
    return toString().startsWith('Null') || _isCallbackType(this);
  }

  bool hasConstructor(String name) {
    return (this is InterfaceType) && (this! as InterfaceType).constructors.any((e) => e.name == name);
  }

  bool _isCallbackType(DartType? type) {
    return (type is FunctionType &&
        (type.returnType is VoidType || type.returnType is DynamicType || type.parameters.isEmpty));
  }
}

extension FormalParameterExtension on FormalParameter {
  bool get isBool =>
      this is SimpleFormalParameter && ((this as SimpleFormalParameter).type?.type?.isDartCoreBool ?? false);

  bool get isNullable =>
      this is SimpleFormalParameter && ((this as SimpleFormalParameter).type?.type?.isNullable ?? false);

  bool get isDynamic => declaredElement?.type is DynamicType;
}

extension ExpressionExtensions on Expression {
  List<String> getFieldsFromProps() {
    if (this is ListLiteral) {
      return (this as ListLiteral)
          .elements
          .whereType<SimpleIdentifier>()
          .map((id) => id.staticElement)
          .map((e) => e?.displayName ?? '')
          .toList();
    }
    return [];
  }
}

extension FunctionBodyExtensions on FunctionBody {
  Expression? get expression => switch (this) {
        BlockFunctionBody(:final block) => block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
        ExpressionFunctionBody(:final expression) => expression,
        _ => null,
      };
  bool get hasReturnStatement {
    return switch (this) {
      final BlockFunctionBody b => b.block.statements.any((e) => e is ReturnStatement),
      ExpressionFunctionBody _ => true,
      _ => false,
    };
  }

  bool get hasReturnThis {
    return switch (this) {
      BlockFunctionBody b => b.block.statements.whereType<ReturnStatement>().first.expression is ThisExpression,
      ExpressionFunctionBody e => e.expression is ThisExpression,
      _ => false,
    };
  }
}

extension ClassDeclarationExtensions on ClassDeclaration {
  List<FieldElement> get fields => declaredElement!.fields
      .where((field) => !field.isStatic)
      .where((field) => !field.isSynthetic)
      .toList(growable: false);

  ({bool found, Expression? expression}) propsReturnExpression() {
    final member =
        members.whereType<MethodDeclaration>().where((e) => e.name.lexeme == 'props' && e.isGetter).firstOrNull;
    if (member == null) return (found: false, expression: null);

    return (found: true, expression: member.body.expression);
  }

  bool get isImmutable => metadata.any((e) => e.name.name.startsWith('immutable'));
  bool get isEquatable => declaredElement != null && equatableChecker.isAssignableFromType(declaredElement!.thisType);
  bool get isWidget => declaredElement != null && widgetChecker.isAssignableFromType(declaredElement!.thisType);
  bool get isCubit => declaredElement != null && cubitChecker.isAssignableFromType(declaredElement!.thisType);
  bool get isBloc => declaredElement != null && blocChecker.isAssignableFromType(declaredElement!.thisType);

  bool get hasCopyWithMethod =>
      members.whereType<MethodDeclaration>().firstWhereOrNull((e) => e.name.lexeme == 'copyWith') != null;
}

extension StringExtensions on String {
  bool get isCamelCase => RegExp(r'(?<=[a-z])[A-Z]').hasMatch(this);
  bool get isPascalCase => RegExp(r'(?<=[A-Z])[a-z]').hasMatch(this);
  String get firstUpper => substring(0, 1).toUpperCase() + substring(1);

  String removeAllSpaces() => replaceAll(' ', '');
  bool get containsOnlyUnderscores => switch (length) {
        0 => false,
        1 => this == '_',
        2 => this == '__',
        3 => this == '___',
        _ => RegExp(r'^_+$').hasMatch(this),
      };

  String removePrefix([String prefix = 'get']) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  String get firstLowerCase => substring(0, 1).toLowerCase() + substring(1);
  List<String> splitOnUppercase() => split(RegExp(r'(?=[A-Z])'));
}

extension IterableExtensions<E> on Iterable<E> {
  // ignore: strict_raw_type
  Iterable<E> orderBy<K extends Comparable>(
    K Function(E element) keySelector, {
    bool ascending = true,
  }) {
    // Convert to a list for sorting
    var sortedList = toList();
    sortedList.sort((a, b) {
      final keyA = keySelector(a);
      final keyB = keySelector(b);
      return ascending ? keyA.compareTo(keyB) : keyB.compareTo(keyA);
    });
    return sortedList;
  }

  Iterable<R> joinWhere<S, R>(Iterable<S> others, bool Function(E, S) test, [R Function(E, S)? resultSelector]) {
    final selector = resultSelector ?? (x, y) => (x, y) as R;

    return expand((x) => others.where((y) => test(x, y)).map((y) => selector(x, y)));
  }

  Iterable<E> except(Iterable<E> other, [dynamic Function(E)? selector]) {
    return selector == null
        ? where((element) => !other.contains(element))
        : where((element) => !other.map<dynamic>(selector).contains(selector(element)));
  }

  Iterable<E> separatedBy(E separator) => indexed.expand((e) => [if (e.$1 > 0) separator, e.$2]);

  int countBy(bool Function(E) predicate) {
    var count = 0;
    for (final element in this) {
      if (predicate(element)) {
        count++;
      }
    }
    return count;
  }

  E? get next => skip(1).firstOrNull;
  E? get previous => skip(-1).firstOrNull;

  Iterable<({int index, E item})> get withIndex sync* {
    var index = 0;
    for (final element in this) {
      yield (index: index++, item: element);
    }
  }

  Iterable<Pair<E>> zipWithNext() sync* {
    if (length < 2) yield* [];

    for (final e in indexed.takeWhile((e) => e.$1 < length - 1)) {
      yield (current: e.$2, next: elementAt(e.$1 + 1));
    }
  }
}

typedef Pair<T> = ({T current, T next});

extension ListExtensions<E> on List<E> {
  Map<T, List<E>> groupBy<T>(T Function(E) selector) {
    final map = <T, List<E>>{};
    for (final element in this) {
      final key = selector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}

extension TokenTypeExtensions on TokenType {
  (TokenType, bool) get invert {
    return switch (this) {
      TokenType.EQ_EQ => (TokenType.BANG_EQ, true),
      TokenType.BANG_EQ => (TokenType.EQ_EQ, true),
      TokenType.GT => (TokenType.LT_EQ, true),
      TokenType.LT => (TokenType.GT_EQ, true),
      TokenType.GT_EQ => (TokenType.LT, true),
      TokenType.LT_EQ => (TokenType.GT, true),
      TokenType.AMPERSAND_AMPERSAND => (TokenType.BAR_BAR, true),
      TokenType.BAR_BAR => (TokenType.AMPERSAND_AMPERSAND, true),
      _ => (this, false),
    };
  }
}

extension LintCodeExtension on LintCode {
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    ErrorSeverity? errorSeverity,
  }) {
    return LintCode(
      name: name ?? this.name,
      problemMessage: problemMessage ?? this.problemMessage,
      correctionMessage: correctionMessage ?? this.correctionMessage,
      uniqueName: uniqueName ?? this.uniqueName,
      url: url ?? this.url,
      errorSeverity: errorSeverity ?? this.errorSeverity,
    );
  }
}

extension AstNodeExtensions on AstNode {
  /// Returns a tuple containing a boolean and an ancestor node of type [T].
  ///
  /// Traverses up the AST from the current node, checking each ancestor node
  /// to see if it satisfies the given [predicate]. If a node of type [T]
  /// that matches the [predicate] is found, returns `(true, node)`.
  /// If no such node is found, returns `(false, null)`.
  ///
  /// - [predicate]: A function that evaluates whether a node of type [T]
  ///   matches certain criteria.
  ///
  /// - Returns: A tuple `(true, node)` if an ancestor node of type [T]
  ///   satisfying the [predicate] is found, otherwise `(false, null)`.
  (bool, T?) getAncestor<T extends AstNode>(bool Function(T) predicate) {
    AstNode? node = this;
    while (node != null) {
      if (node is T && predicate(node)) {
        return (true, node);
      }
      node = node.parent;
    }
    return (false, null);
  }

  /// Returns the depth of the current node in the AST tree, counted from
  /// the root node, until an ancestor node of the current node satisfies
  /// the given [predicate].
  ///
  /// - [predicate]: A function that evaluates whether a node satisfies
  ///   certain criteria.
  ///
  /// - Returns: The depth of the first node that satisfies the [predicate], or
  ///   the depth of the root node if no such node is found.
  int depth(bool Function(AstNode) predicate) {
    int depth = 0;
    AstNode? current = this;
    while (current != null) {
      if (predicate(current)) {
        depth++;
      }
      current = current.parent;
    }
    return depth;
  }
}

extension FormalParameterExtensions on FormalParameter {
  bool get isBuildContext =>
      this is SimpleFormalParameter &&
      (this as SimpleFormalParameter).type != null &&
      (this as SimpleFormalParameter).type.toString() == 'BuildContext';
}
