// ignore_for_file: unused_local_variable

void function() {
  final record = (
    'hello',
    'world',
  );

  final first = record.$1; // LINT
  final second = record.$2; // LINT

  final (x, y) = record; // LINT
}
