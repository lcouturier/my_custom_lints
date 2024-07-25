class AvoidBangOperatorTest {
  AvoidBangOperatorTest? obj;
  int? number;

  void test() {
    number!;
    obj!.number!;
    obj!.toString();
  }
}
