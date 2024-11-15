// ignore_for_file: avoid_print, avoid_nullable_boolean
import 'package:flutter_test/flutter_test.dart';

void fun() {
  bool isGoodResult = true;
  if (isGoodResult == true) {
    isGoodResult = false;
  }

  if (isGoodResult == false) {
    isGoodResult = true;
  }
}

void funInvert() {
  bool isGoodResult = true;
  if (true == isGoodResult) {
    isGoodResult = false;
  }

  if (false == isGoodResult) {
    isGoodResult = true;
  }
}

void withNullValue() {
  String? value = null;
  if (value?.isEmpty != true) {
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
}
