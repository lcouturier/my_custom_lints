// ignore_for_file: boolean_prefixes, avoid_dynamic
class SomeClass {
  var flag = true;
  String _value = '';

  set value(String value) {
    this._value = value;
  }

  String get value => this._value;
}

void function(SomeClass some) {
  some.flag = false; // LINT: Avoid mutating parameters.
  some.value = 'hello'; // LINT: Avoid mutating parameters.
}

void someFunction(int x) {
  x = x + 1;
}

void anotherFunction(List<String> items) {
  items.add('new item');
}

AnotherClass anotherFunction2(int code, String name) {
  return AnotherClass(code: code, name: name);
}

class MyClass {
  void someFunction(int z) {
    z = z + 1;
  }

  void anotherFunction(SomeClass some) {
    some.flag = false; // LINT: Avoid mutating parameters.
    some.value = 'hello'; // LINT: Avoid mutating parameters.
  }
}

class AnotherClass {
  final int code;
  final String name;

  AnotherClass({required this.code, required this.name});
}
