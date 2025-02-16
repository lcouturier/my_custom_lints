// ignore_for_file: pattern_never_matches_value_type, unused_element, unused_import

import 'dart:developer';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:my_custom_lints/src/common/extensions.dart';
import 'package:my_custom_lints/src/common/checker.dart';

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
      if (node.staticType == null) return;
      if (!iterableChecker.isAssignableFromType(node.staticType!)) return;
      if (!node.staticType.hasConstructor('of')) return;
      if (node.constructorName.name?.name != 'from') return;

      final arg = node.argumentList.arguments.first;
      final (foundArgumentType, argumentType) = typeOrNot(arg.staticType);
      final (foundNodeType, nodeType) = typeOrNot(node.staticType);

      bool hasToCheck = (foundArgumentType && !(argumentType!.isDartCoreObject) && argumentType is! DynamicType);
      if (!hasToCheck) return;

      if (!foundArgumentType || !foundNodeType) return;
      if (argumentType != nodeType) return;
      if (argumentType.isNullable && !nodeType.isNullable) return;
      if (!argumentType.isFoundInObjectTypeHierarchy(nodeType!)) return;

      reporter.reportErrorForNode(code, node.constructorName);
    });
  }

  (bool, DartType?) typeOrNot(DartType? type) {
    return switch (type) {
      _ when (type == null) => (false, null),
      _ when (type is! InterfaceType) => (false, null),
      _ when (type.typeArguments.firstOrNull == null) => (false, null),
      _ => (true, type.typeArguments.firstOrNull),
    };
  }

  // bool _isUnnecessaryTypeCheck(
  //   DartType? argType,
  //   DartType? castedType,
  // ) {
  //   if (argType == null || castedType == null) {
  //     return false;
  //   }

  //   if (argType == castedType) {
  //     return true;
  //   }

  //   if (_checkNullableCompatibility(argType, castedType)) {
  //     return false;
  //   }

  //   final objectCastedType = _foundCastedTypeInObjectTypeHierarchy(argType, castedType);
  //   if (objectCastedType == null) {
  //     return true;
  //   }

  //   if (!_checkGenerics(objectCastedType, castedType)) {
  //     return false;
  //   }

  //   return false;
  // }

  // bool _checkNullableCompatibility(DartType objectType, DartType castedType) {
  //   return objectType.isNullable && !castedType.isNullable;
  // }

  // bool _checkGenerics(DartType objectType, DartType castedType) {
  //   if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
  //     return false;
  //   }

  //   final length = objectType.typeArguments.length;
  //   if (length != castedType.typeArguments.length) {
  //     return false;
  //   }

  //   for (var argumentIndex = 0; argumentIndex < length; argumentIndex++) {
  //     if (!_isUnnecessaryTypeCheck(
  //       objectType.typeArguments[argumentIndex],
  //       castedType.typeArguments[argumentIndex],
  //     )) {
  //       return false;
  //     }
  //   }

  //   return true;
  // }
}

extension on DartType {
  bool isFoundInObjectTypeHierarchy(DartType type) {
    return switch ((element == type.element, this is InterfaceType)) {
      (true, _) => true,
      (false, true) => (this as InterfaceType).allSupertypes.any((value) => value.element == type.element),
      _ => false,
    };
  }
}
