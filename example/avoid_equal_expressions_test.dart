// ignore_for_file: unused_local_variable, prefer_const_declarations

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

  String value = (num != num) ? "then" : "else";

  final val1 = num << num; // LINT
  final val2 = num >> num; // LINT
  final val3 = 5 / 5; // LINT
  final val4 = 10 - 10; // LINT
}
