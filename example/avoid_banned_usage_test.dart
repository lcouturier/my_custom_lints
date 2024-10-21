// ignore_for_file: boolean_prefixes, unused_parameter, pattern_never_matches_value_type, unused_local_variable
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
