// ignore_for_file: avoid_invalid_prefix, prefer_enum_with_sentinel_value

enum SomeEnum {
  second,
  first, // LINT: Enum constants do not match the alphabetical order. Try sorting them.
}

enum Sports {
  football,
  basketball,
  baseball,
  none,
  cycling;

  String get name => toString().split('.').last;

  R when<R>({
    R Function()? football,
    R Function()? basketball,
    R Function()? baseball,
    R Function()? none,
    R Function()? cycling,
    required R Function() orElse,
  }) {
    return switch (this) {
      Sports.football => football?.call() ?? orElse(),
      Sports.basketball => basketball?.call() ?? orElse(),
      Sports.baseball => baseball?.call() ?? orElse(),
      Sports.none => none?.call() ?? orElse(),
      Sports.cycling => cycling?.call() ?? orElse(),
    };
  }
}

enum TripsAndTicketsStatus {
  upcoming('UPCOMING'),
  passed('PASSED');

  const TripsAndTicketsStatus(this.value);

  final String value;
}

final class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}
