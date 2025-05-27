// ignore_for_file: avoid_print
class Some {
  final String value;
  final String another;

  const Some(this.value, this.another);

  void someMethod(String value, String another) {
    print(value);
    print(another);
  }
}
