// ignore_for_file: unused_local_variable

void fn() {
  final num = 1;
  final anotherNum = 2;
// LINT
  if (num == anotherNum && num == anotherNum) {
    return;
  }

  final val = '1';

  if (val == val) {
    return;
  }

// LINT
  if (num == anotherNum || num == anotherNum) {
    return;
  }

  final val1 = num << num; // LINT
  final val2 = num >> num; // LINT
  final val3 = 5 / 5; // LINT
  final val4 = 10 - 10; // LINT
}