// ignore_for_file: pattern_never_matches_value_type, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/utils.dart';

class PreferIterableOfRule extends DartLintRule {
  static const lintName = 'prefer_iterable_of';

  const PreferIterableOfRule()
      : super(
          code: const LintCode(
            name: lintName,
            problemMessage: 'Use Iterable.of instead.',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.staticType.isIterableOrSubclass &&
          node.constructorName.name?.name == 'from' &&
          node.staticType.hasConstructor('of')) {
        final arg = node.argumentList.arguments.first;
        final argumentType = _getType(arg.staticType);
        final castedType = _getType(node.staticType);

        if (argumentType != null &&
            !argumentType.isDartCoreObject &&
            // ignore: deprecated_member_use
            !argumentType.isDynamic &&
            _isUnnecessaryTypeCheck(castedType, argumentType)) {
          reporter.reportErrorForNode(code, node.constructorName);
        }
      }
    });
  }

  // final arg = node.argumentList.arguments.first;

  // final argumentType = _getType(arg.staticType);
  // final castedType = _getType(node.staticType);
  // if (argumentType != null &&
  //     !argumentType.isDartCoreObject &&
  //     // ignore: deprecated_member_use
  //     !argumentType.isDynamic &&
  //     _isUnnecessaryTypeCheck(castedType, argumentType)) {
  //   reporter.reportErrorForNode(code, node.constructorName);
  // }

  DartType? _getType(DartType? type) {
    if (type == null || type is! InterfaceType) {
      return null;
    }

    final typeArgument = type.typeArguments.firstOrNull;
    if (typeArgument == null) {
      return null;
    }

    return typeArgument;
  }

  bool _isUnnecessaryTypeCheck(
    DartType? objectType,
    DartType? castedType,
  ) {
    if (objectType == null || castedType == null) {
      return false;
    }

    if (objectType == castedType) {
      return true;
    }

    if (_checkNullableCompatibility(objectType, castedType)) {
      return false;
    }

    final objectCastedType = _foundCastedTypeInObjectTypeHierarchy(objectType, castedType);
    if (objectCastedType == null) {
      return true;
    }

    if (!_checkGenerics(objectCastedType, castedType)) {
      return false;
    }

    return false;
  }

  bool _checkNullableCompatibility(DartType objectType, DartType castedType) {
    final isObjectTypeNullable = isNullableType(objectType);
    final isCastedTypeNullable = isNullableType(castedType);

    // Only one case `Type? is Type` always valid assertion case.
    return isObjectTypeNullable && !isCastedTypeNullable;
  }

  DartType? _foundCastedTypeInObjectTypeHierarchy(
    DartType objectType,
    DartType castedType,
  ) {
    // ignore: deprecated_member_use
    if (objectType.element2 == castedType.element2) {
      return objectType;
    }

    if (objectType is InterfaceType) {
      return objectType.allSupertypes
          // ignore: deprecated_member_use
          .firstWhereOrNull((value) => value.element2 == castedType.element2);
    }

    return null;
  }

  bool _checkGenerics(DartType objectType, DartType castedType) {
    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final length = objectType.typeArguments.length;
    if (length != castedType.typeArguments.length) {
      return false;
    }

    for (var argumentIndex = 0; argumentIndex < length; argumentIndex++) {
      if (!_isUnnecessaryTypeCheck(
        objectType.typeArguments[argumentIndex],
        castedType.typeArguments[argumentIndex],
      )) {
        return false;
      }
    }

    return true;
  }
}
