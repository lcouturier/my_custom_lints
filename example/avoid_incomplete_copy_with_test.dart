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

  PersonWithNullable copyWith({String? name, String? Function()? nickName}) {
    return PersonWithNullable(
      name: name ?? this.name,
      nickName: nickName != null ? nickName() : this.nickName,
      age: this.age,
    );
  }
}
