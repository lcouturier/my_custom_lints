// ignore_for_file: unused_local_variable

const numbers = [1, 2, 3];

final a = numbers[0];

final b = numbers.elementAt(0);

final listOfLists = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9],
];

final c = numbers[numbers.length - 1];

final d = numbers.elementAt(numbers.length - 1);

final e = numbers[numbers.length];

void fn() {
  final value = listOfLists[0][1];
}
