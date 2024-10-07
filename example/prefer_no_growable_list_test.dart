void fn() {
  final result = [1, 2, 3, 4, 5].toList(growable: false);
  // ignore: avoid_print
  print(result);
}

class PreferNoGrowableListTest {
  void fn() {
    final result = [1, 2, 3, 4, 5].toList();
    // ignore: avoid_print
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
