void fn(Iterable<int> numbers) {
  numbers.where((n) => n.isEven).isNotEmpty;

  numbers.where((n) => n == 0).isNotEmpty;

  numbers.any((n) => n > 0);

  final result = numbers.where((n) => n == 0);
  // ignore: avoid_print
  print(result);
}
