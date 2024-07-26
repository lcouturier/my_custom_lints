import 'package:equatable/equatable.dart';

sealed class MyBaseClass extends Equatable {
  MyBaseClass();

  @override
  List<Object?> get props => [];
}

class MyClass extends MyBaseClass {
  final String value;

  MyClass(this.value);

  @override
  List<Object?> get props => [value];
}

sealed class AnotherClass extends Equatable {}
