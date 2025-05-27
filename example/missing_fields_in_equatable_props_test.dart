// ignore_for_file: unused_field

import 'package:equatable/equatable.dart';

class PersonMissingFields extends Equatable {
  final String name;
  final int age;
  final String? nickName;
  final bool isAdult;

  PersonMissingFields({required this.name, required this.age, required this.nickName, required this.isAdult});

  @override
  List<Object?> get props => [name, age, nickName];
}
