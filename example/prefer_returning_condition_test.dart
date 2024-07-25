import 'dart:math';

class PreferReturningConditionTest {
  bool func() {
    if (!Random().nextBool()) {
      return true;
    } else {
      return false;
    }
  }
}
