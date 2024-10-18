class SomeClass {
  String someString = 'some';
  String another = 'another';

  void update(String str) {
    someString = another = str; // LINT: Avoid multi assignments. Try moving each assignment to its own line.

    final instance = SomeClass();
    instance.another = someString = str; // LINT: Avoid multi assignments. Try moving each assignment to its own line.
  }
}
