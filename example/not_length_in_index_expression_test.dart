void fn(List<int> numbers) {
  // ignore: prefer_iterable_last
  final result = numbers[numbers.length];

  // ignore: unused_local_variable, prefer_iterable_last
  final result2 = numbers[numbers.length - 1];

  // ignore: prefer_iterable_last
  final result3 = numbers.elementAt(numbers.length);

  // ignore: avoid_print
  print(result);
  // ignore: avoid_print
  print(result2);
  // ignore: avoid_print
  print(result3);
}
