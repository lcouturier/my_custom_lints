// ignore_for_file: avoid_nullable_boolean, avoid_banned_usage
void fun() {
  bool isGoodResult = true;
  if (isGoodResult) {
    isGoodResult = false;
  }

  if (!isGoodResult) {
    isGoodResult = true;
  }
}

void funInvert() {
  bool isGoodResult = true;
  if (isGoodResult) {
    isGoodResult = false;
  }

  if (!isGoodResult) {
    isGoodResult = true;
  }
}

void withNullValue() {
  final int sum = 15;
  String? value = null;
  if (sum == 15 && value?.isEmpty != true) {
    print(value);
  }

  bool? isEmpty = null;
  if (isEmpty == true) {
    print(value);
  }

  List<String>? list = null;
  if (list?.isEmpty == true) {
    print(list);
  }

  List<String>? another = null;
  if (another?.isEmpty == false) {
    print(list);
  }
}
