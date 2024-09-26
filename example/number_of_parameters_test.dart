// ignore_for_file: unused_parameter
import 'dart:developer';

String other(String a, String b) {
  return a;
}

class NumberOfParameters {
  void numberOfParameters(String a, String b, String c, String e, String g) {
    /// [numberOfParameters] has 3 parameters
  }

  String other(String a, String b) {
    return a;
  }

  void unusedParameter(String a) {}

  void usedParameter(String a) {
    log(a);
  }

  void numberOfParametersDeprecated(String a, String b, String c, String d, String e, String f, String g) {
    /// [numberOfParameters] has 3 parameters
  }
}

class MyClass {
  final int a;
  final int b;
  final int c;
  final int d;
  final int e;
  final int f;
  final int g;

  MyClass(this.a, this.b, this.c, this.d, this.e, this.f, this.g);

  void doSomething() {}

  MyClass copyWith({
    int? a,
    int? b,
    int? c,
    int? d,
    int? e,
    int? f,
    int? g,
  }) {
    return MyClass(
      a ?? this.a,
      b ?? this.b,
      c ?? this.c,
      d ?? this.d,
      e ?? this.e,
      f ?? this.f,
      g ?? this.g,
    );
  }
}
