// ignore_for_file: avoid_print, prefer_any_or_every, unused_local_variable
int foo() {
  return 5;
}

int foo2() => 5;

void bar() {
  print('whatever');
}

int baz() {
  return foo();
}

void main() {
  final collection = [1, 2, 3, 4, 5];

  collection.where((item) => item.isEven).isNotEmpty; // LINT

  bar();
  foo(); // LINT: return value is silently ignored
  final value = foo2();

  final str = "Hello there";
  str.substring(5); // LINT: Strings are immutable and the return value should be handled

  final date = new DateTime(2018, 1, 13);
  date.add(Duration(days: 1, hours: 23)); // LINT: Return value ignored, DateTime is immutable
}
