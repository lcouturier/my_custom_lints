void fnBad1(List<String> values) {
  int other = 0;
  bool? flag;

  if (flag = values.isEmpty) {} // LINT
}

void fnBad2(List<String> values) {
  bool? flag;
  int other = 0;

  if (flag ??= values.isEmpty) {} // LINT
}

void fnGood(List<String> values) {
  bool? flag;

  flag ??= values.isEmpty;
  if (flag) {}
}
