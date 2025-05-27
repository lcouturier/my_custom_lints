// ignore_for_file: unused_local_variable

void unconditional() {
  final list = <int>[];

  for (final item in list) {
    continue; // LINT: Avoid unconditional break statements. This loop is always interrupted after one iteration. Try removing this statement or call it conditionally.
  }

  for (final item in list) {
    break; // LINT: Avoid unconditional break statements. This loop is always interrupted after one iteration. Try removing this statement or call it conditionally.
  }

  for (final item in list) {
    return; // LINT: Avoid unconditional break statements. This loop is always interrupted after one iteration. Try removing this statement or call it conditionally.
  }

  for (final item in list) {
    throw ''; // LINT: Avoid unconditional break statements. This loop is always interrupted after one iteration. Try removing this statement or call it conditionally.
  }
}
