// ignore_for_file: unused_local_variable, unused_element

void function() {
  final record = (
    'hello',
    'world',
  );

  final first = record.$1; // LINT
  final second = record.$2; // LINT

  final (x, y) = record;
}

extension on Iterable<String> {
  /// Returns an iterable with the elements of this iterable, separated by
  /// [separator].
  ///
  /// For example, if this is the iterable `['a', 'b', 'c']`, then
  /// `separatedBy(',')` returns an iterable that produces the elements
  /// `['a', ',', 'b', ',', 'c']`.
  ///
  /// If this iterable is empty, the returned iterable is also empty.
  ///
  /// If [separator] is the empty string, then the returned iterable is the same
  /// as this one.
  Iterable<String> separatedBy(String separator) {
    return indexed.expand((e) => [if (e.$1 > 0) separator, e.$2]);
  }
}

typedef IndexOrNot = (bool found, int index);

extension on Iterable<String> {
  /// Similar to [List.indexWhere], but returns a tuple with a boolean indicating
  /// whether an element was found or not.
  ///
  /// If an element is found, the boolean is `true` and the index is the index of
  /// the element.
  ///
  /// If no element is found, the boolean is `false` and the index is `-1`.
  ///
  /// This is useful when you want to handle both cases, but don't want to make
  /// a separate `if` statement for it.
  IndexOrNot findIndex(bool Function(String element) test) {
    for (final element in this.indexed) {
      if (test(element.$2)) {
        return (true, element.$1);
      }
    }
    return (false, -1);
  }
}
