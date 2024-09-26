typedef B = void Function();

typedef C = void Function()?;
typedef D = Function(int index);
typedef E = Function({required int index});

typedef MyFunction = Function(); // No explicit return type
typedef DynamicReturner = dynamic Function(int); // Explicit dynamic return type

typedef Test = Function({required int index});

typedef IntReturner = int Function(String); // Explicit non-dynamic return type

class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  getString1() => 'Person(name: $name, age: $age)';
  getString2() {
    return 'Person(name: $name, age: $age)';
  }
}

getValue1() => '';

getValue2() {
  return '';
}

printValue() {
  // ignore: avoid_print
  print('nothing');
}
