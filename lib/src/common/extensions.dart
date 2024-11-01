// Extension to check if a class is an Equatable class

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/utils.dart';

extension DartTypeExtensions on DartType {
  bool get isNullableList {
    final predicates = [
      () => this is InterfaceType,
      () => element?.name == 'List',
      () => nullabilitySuffix == NullabilitySuffix.question,
    ];

    return predicates.every((e) => e());
  }
}

extension RecordTypeExtensions on RecordType {
  bool get isMixed => positionalFields.isNotEmpty && namedFields.isNotEmpty;
}

extension DartTypeNullableExtensions on DartType? {
  bool get isNullable => isNullableType(this);
  bool get isWidget => this?.getDisplayString(withNullability: false) == 'Widget';

  bool get isCallbackType {
    return toString().startsWith('Null') || _isCallbackType(this);
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
}

extension StringExtensions on String {
  bool get isCamelCase => RegExp(r'(?<=[a-z])[A-Z]').hasMatch(this);
  bool get isPascalCase => RegExp(r'(?<=[A-Z])[a-z]').hasMatch(this);

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
}

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
