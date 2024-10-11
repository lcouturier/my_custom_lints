import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class PersonWithoutNullable extends Equatable {
  final String firstName;
  final String lastName;
  final int age;

  PersonWithoutNullable({required this.firstName, required this.lastName, required this.age});

  @override
  List<Object?> get props => [firstName, lastName, age];
}

class PersonWithNullable extends Equatable {
  final String firstName;
  final String lastName;
  final String? nickName;
  final int age;

  PersonWithNullable({required this.firstName, required this.lastName, this.nickName, required this.age});

  @override
  List<Object?> get props => [firstName, lastName, nickName, age];
}

@immutable
class PersonWithImmatable {
  final String firstName;
  final String lastName;
  final int age;

  PersonWithImmatable({required this.firstName, required this.lastName, required this.age});
}

class PersonWithoutNamedParameters {
  final String firstName;
  final String lastName;
  final int age;

  PersonWithoutNamedParameters(this.firstName, this.lastName, this.age);
}
