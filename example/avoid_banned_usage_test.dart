// ignore_for_file: boolean_prefixes, unused_parameter, pattern_never_matches_value_type, unused_local_variable, avoid_banned_usage, avoid_dynamic
import 'package:flutter/material.dart';

class SomeType {
  final bool field;
  SomeType({required this.field});
}

// LINT: Use of this type is not allowed (Do not use SomeType here.).
void function(SomeType someParam) {
  // LINT: Use of this type is not allowed (Do not use SomeType here.).
  bool value = false;
  final f = SomeType(field: true);
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(DateTime.now().toString()), selected: true);
  }
}

void main() {
  const array = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  final copy = List<int>.from(array); // LINT
  final numList = List<int>.from(array); // LINT

  final intList = List<int>.from(numList);

  final unspecifedList = List.from(array); // LINT

  final dynamicArray = <dynamic>[1, 2, 3];
  final dynamicCopy = List.from(dynamicArray);
}
