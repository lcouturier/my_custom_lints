// ignore_for_file: boolean_prefixes, unused_parameter
void someFunction1(String name, {required bool isExternal, required bool isTemporary}) {
  // ignore: avoid_print
  print(name);
  // ignore: avoid_print
  print(isExternal);
  // ignore: avoid_print
  print(isTemporary);
}

void someFunction2(String name, bool isExternal, bool isTemporary) {
  // ignore: avoid_print
  print(name);
  // ignore: avoid_print
  print(isExternal);
  // ignore: avoid_print
  print(isTemporary);
}

void fn2(bool p1) {
  // ignore: avoid_print
  print(p1);
}

class MyClass {
  final bool p1;
  final bool p2;
  final bool p3;

  MyClass(this.p1, this.p2, this.p3);

  void fn(String name, bool p1, bool p2, bool p3) {
    // ignore: avoid_print
    print(p1);
    // ignore: avoid_print
    print(p2);
    // ignore: avoid_print
    print(p3);
  }
}
