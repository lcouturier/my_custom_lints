// ignore_for_file: unused_parameter
import 'package:flutter/foundation.dart';

@immutable
class Person {
  final String name;
  final String nickName;
  final int age;

  Person({required this.name, required this.nickName, required this.age});

  Person copyWith({String? name, String? nickName}) {
    return Person(
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      age: age ?? this.age,
    );
  }
}

@immutable
class PersonWithNullable {
  final String name;
  final String? nickName;
  final int age;

  const PersonWithNullable({required this.name, this.nickName, required this.age});

  PersonWithNullable copyWith({String? name, int? age}) {
    return PersonWithNullable(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

@immutable
class MyClass {
  final String name;
  final int age;

  MyClass({required this.name, required this.age});

  MyClass copyWith({String? name, int? age}) {
    return this;
  }
}
