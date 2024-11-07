// ignore_for_file: unused_element

import 'package:flutter/material.dart';

// addVariableDeclaration
dynamic x = 10; // LINT

// LINT
// addFormalParameterList
String concat(dynamic a, dynamic b) {
  return a + b;
}

// addFunctionDeclaration
(dynamic,) _getValue() => (null,); // LINT

class MyClass {
  // addGenericFunctionType
  Function()? onDrag;
  dynamic Function()? onPress;

  dynamic getValue() => (null,); // LINT
}

class name extends StatelessWidget {
  // addGenericFunctionType
  final Function(String) onRecentPlaceSelected;
  final Function(String) onFavoritePlaceSelected;
  final dynamic Function(String) onAddFavoritePlaceSelected;

  const name(
      {super.key,
      required this.onRecentPlaceSelected,
      required this.onFavoritePlaceSelected,
      required this.onAddFavoritePlaceSelected,
      required this.value});

  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  List getItems() {
    return [1, 2, 3].toList(growable: false);
  }
}

List<int> getItems() {
  return [1, 2, 3].toList(growable: false);
}
