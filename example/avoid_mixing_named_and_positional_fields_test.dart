final record1 = ('hello',);
final record2 = (
  'hello',
  hi: 'world'
); // LINT: Avoid records with both named and positional fields. Try converting all fields to named.

class MyClass {
  final (
    String, {
    int named
  }) field; // LINT: Avoid records with both named and positional fields. Try converting all fields to named.

  const MyClass(this.field);

  (int, {int named}) calculate() =>
      (1, named: 0); // LINT: Avoid records with both named and positional fields. Try converting all fields to named.
}
