void fn() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}

// ignore: cyclomatic_complexity
void fn2(int a) {
  if (a == 1) {
  } else if (a == 2) {
  } else if (a == 3) {
    if (true) {
      if (true) {}
    }
  } else if (a == 4) {}
}
