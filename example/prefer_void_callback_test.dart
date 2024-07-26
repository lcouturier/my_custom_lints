import 'package:flutter/foundation.dart' show VoidCallback;

typedef A = VoidCallback;

typedef B = void Function();

typedef C = void Function()?;
typedef D = void Function(int index);
typedef E = void Function({required int index});

typedef MyFunction = Function(); // No explicit return type
typedef DynamicReturner = dynamic Function(int); // Explicit dynamic return type

typedef Test = Function({required int index});

typedef IntReturner = int Function(String); // Explicit non-dynamic return type

class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  getString() => 'Person(name: $name, age: $age)';
}

getValue() {
  return '';
}
