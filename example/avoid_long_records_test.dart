final record = ('hello', 'world', 'and', 'this', 'is', 'also', 'a field'); // LINT

final other = ('hello', 'world');

class MyClass {
  final (String, {int named}) field;

  const MyClass(this.field);

  (int, int, String, int, double, num, num) getData() => (1, 2, 'hello', 3, 4.0, 5, 6); // LINT
}
