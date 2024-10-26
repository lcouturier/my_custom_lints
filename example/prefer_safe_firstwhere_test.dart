// ignore_for_file: unused_local_variable

void fn() {
  final list = [1, 2, 3, 4, 5];
  final items = list.firstWhere((e) => e > 10);

  final noValue = list.singleWhere((e) => e > 10);

  final last = list.lastWhere((e) => e > 10);
}
