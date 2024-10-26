// ignore_for_file: avoid_print
void fn() {
  final result = [1, 2, 3, 4, 5].toList();

  print(result);
}

class PreferNoGrowableListTest {
  void fn() {
    final result = [1, 2, 3, 4, 5].toList();

    result.add(1);

    print(result);
  }

  void fn2() {
    final value = 1;
    switch (value) {
      case 1:
        print(1);
        break;
      case _:
        print('other');
        break;
    }
  }
}
