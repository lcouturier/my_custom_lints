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
