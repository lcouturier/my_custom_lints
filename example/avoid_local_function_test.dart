bool someFunction(String externalValue) {
  final value = 'some value';

  return isValid() && externalValue != value;
}

// LINT
bool isValid() {
  return true;
}
