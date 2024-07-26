// ignore_for_file: literal_only_boolean_expressions, prefer_early_return
// ignore_for_file: no_empty_block, prefer_match_file_name

void cyclomaticComplexity() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {}
      }
    }
  }
}

class A {
  void cyclomaticComplexity() {
    if (true) {
      if (true) {
        if (true) {
          if (true) {
            if (true) {
              if (true) {}
            }
          }
        }
      }
    }
  }

  void simple() {
    if (true) {}
  }
}
