// ignore_for_file: unused_local_variable

void fn() {
  final list = <int>[];
  final sum = list.reduce((a, b) => a + b);
  // LINT: Calling 'reduce' on an empty collection will throw an exception. Try checking if this collection is not empty first.

  final sum2 = list.isEmpty ? 0 : list.reduce((a, b) => a + b);

  if (list.isNotEmpty) {
    final sum3 = list.reduce((a, b) => a + b);
  }
}
