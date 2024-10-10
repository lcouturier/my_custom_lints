// ignore_for_file: unused_catch_clause, avoid_print

void invalid() {
  try {
    print('valid');
  } on Object catch (error) {
    rethrow; // LINT
  }
}

void valid() {
  try {
    print('valid');
  } on Object catch (error) {
    if (error is Exception) {
      return;
    }

    rethrow;
  }
}
