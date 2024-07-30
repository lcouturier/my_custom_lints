void fn(Iterable<int> numbers) {
  numbers.where((n) => n.isEven).isNotEmpty;

  numbers.where((n) => n == 0).isNotEmpty;

  numbers.where((n) => n > 0).isNotEmpty;
}
