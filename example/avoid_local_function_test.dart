bool someFunction(String externalValue) {
  final value = 'some value';

  // LINT
  bool isValid() {
    // some
    // additional
    // logic

    return true;
  }

  return isValid() && externalValue != value;
}
