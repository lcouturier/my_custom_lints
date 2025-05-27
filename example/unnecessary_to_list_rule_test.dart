// ignore_for_file: unused_local_variable

void main() {
  final list1 = [1, 2, 3];
  final list2 = [...list1.toList()]; // This should be flagged
}
