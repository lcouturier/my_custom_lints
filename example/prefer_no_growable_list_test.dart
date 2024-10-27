// ignore_for_file: avoid_print
void fn1() {
  final result = [1, 2, 3, 4, 5].toList();

  print(result);
}

class PreferNoGrowableListTest {
  List<int> fn2() {
    final result = [1, 2, 3, 4, 5].toList();

    result.add(6);

    print(result);
    return result.toList();
  }

  void fn3() {
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
