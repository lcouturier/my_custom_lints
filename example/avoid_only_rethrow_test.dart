// ignore_for_file: unused_catch_clause, avoid_print

void invalid() {
  try {
    print('valid');
  } on Object catch (error) {
    rethrow; // LINT
  }
}

void invalidMultiClauses() {
  try {
    print('valid');
  } on IndexError catch (error) {
    rethrow;
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
  }
}

void throwLitteral() {
  try {
    print('valid');
  } on Object catch (error) {
    throw 'error'; // LINT
  }
}

class MyError implements Exception {
  MyError(this.message);

  final String message;
}
