// ignore_for_file: boolean_prefixes, unused_parameter, pattern_never_matches_value_type, unused_local_variable
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
