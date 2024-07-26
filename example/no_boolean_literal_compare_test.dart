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
