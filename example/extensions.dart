// ignore_for_file: prefer_usage_of_value_getter

import 'prefer_iterable_first_last_test.dart';
import 'state_test.dart';

extension StringExtensions on String {
  String plus({Object? element}) => padRight(length + 1, element?.toString() ?? '');
  String add({Object? element}) => this + (element?.toString() ?? '');
}

extension IterableExtensions<T> on List<T> {
  T aggregate(T Function(T, T) combine, T Function() orElse) {
    // ignore: avoid_unsafe_reduce
    return this.isEmpty ? orElse() : this.reduce(combine);
  }

  Iterable<R> selectMany<E, R>(List<E> Function(T) selector, R Function(E, T) resultSelector) {
    return this.expand((e) => selector(e).map((r) => resultSelector(r, e)));
  }
}
