// ignore_for_file: lines_longer_than_80_chars, copy_with_method_field_check

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

typedef MyFunc = void Function(bool);

@immutable
class Person {
  final String name;
  final String firstName;
  final int age;
  const Person(this.name, this.age, this.firstName);

  bool get isAdult => age >= 18;
  bool get minor => age < 18;

  // ignore: unused_parameter, prefer_named_bool_parameters
  bool adult(bool valid) {
    return age >= 18;
  }

  bool get adultOrMinor => age >= 18 || age < 18;

  Person get incrementAge => copyWith(age: age + 1);

  Person copyWith({String? name, int? age}) {
    return Person(
      name ?? this.name,
      age ?? this.age,
      this.firstName,
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

const debugMode = true;

// "at" is a valid prefix since we specified it in the analysis_options.yaml.
const atOrigin = true;

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  bool get origin => x == 0 && y == 0;

  bool samePoint(covariant Point other) => x == other.x && y == other.y;
}

class Point3D extends Point {
  final double z;

  const Point3D(super.x, super.y, this.z);

  @override
  bool samePoint(Point3D other) => super.samePoint(other) && z == other.z;
}

bool shouldsamePoint(Point a, Point b) => a.x == b.x && a.y == b.y;

extension PointExtension on Point {
  bool get onXAxis => y == 0;
}
