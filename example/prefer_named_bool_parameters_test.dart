// ignore_for_file: boolean_prefixes, avoid_print, duplicate_ignore, unused_parameter, avoid_nullable_boolean
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

class EditablePassenger {
  final String name;
  final bool isExternal;
  final bool isTemporary;

  EditablePassenger({required this.name, required this.isExternal, required this.isTemporary});
}

void fn3(EditablePassenger editablePassenger, String? pet, bool? selected) {
  print(pet ?? 'null');
  print(selected ?? 'null');
}

class MyClass {
  final bool p1;
  final bool p2;
  final bool p3;

  MyClass(this.p1, this.p2, this.p3);

  void fn(String name, bool p1, bool? p2, bool p3) {
    // ignore: avoid_print
    print(p1);
    // ignore: avoid_print
    print(p2);
    // ignore: avoid_print
    print(p3);
  }

  void fn3(int max, String? pet, bool? selected) {
    print(pet ?? 'null');
    print(selected ?? 'null');
  }
}
