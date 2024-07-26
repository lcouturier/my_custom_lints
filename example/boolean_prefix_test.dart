// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';

class Option<T> {
  final T? value;
  const Option(this.value);

  factory Option.none() => const Option(null);
  factory Option.of(T value) => Option(value);

  bool get hasValue => value != null;
  bool get isFilled => hasValue;
  bool get isEmpty => !hasValue;

  T getOrElse(T Function() defaultValue) => value ?? defaultValue();

  @override
  String toString() => 'Option($value)';

  bool get isNone => !hasValue;
  bool get isSome => hasValue;
  Option<T> getOrElseGet(Option<T> Function() defaultValue) => value != null ? this : defaultValue();
}

@immutable
class Person {
  final String name;
  final int age;
  const Person(this.name, this.age);

  bool get isAdult => age >= 18;
  bool get isMinor => age < 18;

  bool get adultOrMinor => age >= 18 || age < 18;

  Person get incrementAge => copyWith(age: age + 1);

  Person copyWith({String? name, int? age}) {
    return Person(
      name ?? this.name,
      age ?? this.age,
    );
  }

  @override
  String toString() {
    return 'Person(name: $name, age: $age)';
  }

  @override
  int get hashCode => Object.hash(name, age);

  @override
  bool operator ==(Object other) {
    if (other is Person) {
      return other.name == name && other.age == age;
    }
    return false;
  }
}
