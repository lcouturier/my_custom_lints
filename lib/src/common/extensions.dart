// Extension to check if a class is an Equatable class

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import 'package:analyzer/dart/element/type.dart';
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

extension FormalParameterExtension on FormalParameter {
  bool get isBool {
    return this is SimpleFormalParameter && ((this as SimpleFormalParameter).type!.type?.isDartCoreBool ?? false);
  }
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

extension ClassDeclarationExtensions on ClassDeclaration {
  List<FieldElement> get fields => declaredElement!.fields
      .where((field) => !field.isStatic)
      .where((field) => !field.isSynthetic)
      .toList(growable: false);

  Expression? getPropsReturnExpression() {
    for (final member in members) {
      if (member is MethodDeclaration && member.name.lexeme == 'props' && member.isGetter) {
        if (member.body is ExpressionFunctionBody) {
          return (member.body as ExpressionFunctionBody?)?.expression;
        }
      }
    }
    return null;
  }

  bool get isImmutable => metadata.any((e) => e.name.name.startsWith('immutable'));

  bool get isEquatable => declaredElement != null && equatableChecker.isAssignableFromType(declaredElement!.thisType);
}

extension StringExtensions on String {
  bool get containsOnlyUnderscores => switch (length) {
        0 => false,
        1 => this == '_',
        2 => this == '__',
        3 => this == '___',
        _ => RegExp(r'^_+$').hasMatch(this),
      };
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
}

extension FunctionBodyExtensions on FunctionBody {
  bool get hasReturnStatement {
    return switch (this) {
      final BlockFunctionBody b => b.block.statements.any((e) => e is ReturnStatement),
      ExpressionFunctionBody _ => true,
      _ => false,
    };
  }
}
