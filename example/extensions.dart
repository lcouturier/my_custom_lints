extension StringExtensions on String {
  String plus({Object? element}) => padRight(length + 1, element?.toString() ?? '');
  String add({Object? element}) => this + (element?.toString() ?? '');
}
