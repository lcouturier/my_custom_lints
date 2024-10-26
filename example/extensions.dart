// ignore_for_file: prefer_usage_of_value_getter

extension StringExtensions on String {
  String plus({Object? element}) => padRight(length + 1, element?.toString() ?? '');
  String add({Object? element}) => this + (element?.toString() ?? '');
}

extension IterableExtensions<T> on List<T> {
  T aggregate(T Function(T, T) combine, T Function() orElse) {
    // ignore: avoid_unsafe_reduce
    return this.isEmpty ? orElse() : this.reduce(combine);
  }
}
