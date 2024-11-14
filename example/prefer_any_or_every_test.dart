// ignore_for_file: avoid_ignoring_return_values
void fn() {
  final collection = [1, 2, 3, 4, 5];

  collection.where((item) => item.isEven).isNotEmpty; // LINT

  collection.where((item) => item.isEven).isEmpty; // LINT
  collection.where((item) => !item.isEven).isEmpty; // LINT

  collection.where((item) => true).isEmpty; // LINT

  collection.where((item) => item is String).isEmpty; // LINT
  collection.where((item) => item is! String).isEmpty; // LINT

  collection.where((item) => item == 4).isEmpty; // LINT
  collection.where((item) => item != 4).isEmpty; // LINT
  collection.where((item) => !(item != 4)).isEmpty; // LINT
}

void fn2(Iterable<int> numbers) {
  numbers.where((n) => n.isEven).isEmpty;

  numbers.where((n) => n == 0).isEmpty;

  numbers.where((n) => n > 0).isEmpty;

  numbers.where((n) => n % 3 == 0).isEmpty;

  numbers.where((n) => isMultipleOfThree(n)).isEmpty;

  numbers.where((n) => !isMultipleOfThree(n)).isEmpty;

  numbers.where(isMultipleOfThree).isEmpty;

  numbers.where((n) {
    return n.isEven;
  }).isEmpty;

  numbers.where((n) {
    return n == 0;
  }).isEmpty;

  numbers.where((n) {
    return n > 0;
  }).isEmpty;

  numbers.where((n) {
    return n % 3 == 0;
  }).isEmpty;

  numbers.where((n) {
    return isMultipleOfThree(n);
  }).isEmpty;
}

bool isMultipleOfThree(int number) => number % 3 == 0;

class MyClass {
  final List<String> names;

  MyClass({required this.names});

  bool get hasAnyTest => names.where((e) => e.startsWith("test")).isNotEmpty;
  bool get hasEveryTest => names.where((e) => e.startsWith("test")).isEmpty;

  bool isAnyTest() {
    return names.where((e) => e.startsWith("test")).isNotEmpty;
  }
}
