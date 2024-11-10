// ignore_for_file: unused_local_variable, unreachable_switch_case, dead_code, avoid_print

(int x, int y) getPoint() => (1, 1);

void main() {
  final value = switch (getPoint()) {
    // LINT: Avoid nested switch expressions. Try rewriting the code to remove nesting.
    (int y, int x) => switch (x) {
        > 0 => 5,
        == 0 => 6,
        _ => 7,
      },
    (int first, int second) => 2,
    (int x, int y) => 3,
  };
  print(value);
}
