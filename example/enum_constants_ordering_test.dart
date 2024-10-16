// ignore_for_file: avoid_invalid_prefix

enum SomeEnum {
  second,
  first, // LINT: Enum constants do not match the alphabetical order. Try sorting them.
}

enum Sports {
  football,
  basketball,
  baseball,
  none,
  cycling;

  String get name => toString().split('.').last;
}
