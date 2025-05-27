// ignore_for_file: unused_local_variable, avoid_ignoring_return_values, avoid_print

void fn(Iterable<int> numbers) {
  numbers.where((n) => n.isEven).isNotEmpty;

  final isEmpty = numbers.length != 0;
  print(isEmpty);

  final isNotEmpty = numbers.where((e) => e.isEven).length == 0;
  print(isNotEmpty);

  numbers.where((n) => n == 0).isNotEmpty;

  numbers.any((n) => n > 0);

  final value = "";
  final emptyStz1 = value.length == 0;
  final emptyStz2 = value.length != 0;
  final emptyStz3 = value.length > 0;

  final result = numbers.where((n) => n == 0);
  print(result);
}
