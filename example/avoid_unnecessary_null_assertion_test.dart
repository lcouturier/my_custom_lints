class AnotherGuy {
  final String name;
  final String? firstName;
  final int age;

  AnotherGuy({
    required this.name,
    this.firstName,
    required this.age,
  });
}

void display() {
  final p = AnotherGuy(name: 'test', age: 22);
  if (p.firstName != null) {
    print(p.firstName!);
  }
}

String process() {
  final p = AnotherGuy(name: 'test', age: 22);
  // ignore: avoid_unnecessary_null_assertion
  if (p.firstName != null) {
    print(p.firstName!);
    return p.firstName!;
  } else {
    throw Exception("No first name");
  }
}

String processWith() {
  final p = AnotherGuy(name: 'test', age: 22);
  // ignore: avoid_unnecessary_null_assertion
  if (p.firstName != null)
    return p.firstName!;
  else
    throw Exception("No first name");
}
