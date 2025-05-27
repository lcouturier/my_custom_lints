// ignore_for_file: avoid_dynamic, unused_local_variable
void main() {
  const array = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  final copy = List<int>.from(array); // LINT
  final numList = List<int>.from(array); // LINT
  final intList = List<int>.from(numList);

  final unspecifedList = List.from(array); // LINT

  final dynamicArray = <dynamic>[1, 2, 3];
  final dynamicCopy = List.from(dynamicArray);
}
