import 'package:flutter_test/flutter_test.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

void main() {
  test('Test plus', () async {
    final result = ["label1", "label2", 'label3', 'label4'].fold('', (p0, p1) => '$p0 $p1').plus(element: ',');
    print(result);

    final result2 = ["label1", "label2", 'label3', 'label4'].fold('', (p0, p1) => '$p0 $p1') + ',';
    print(result2);
  });

  test('Test add', () async {
    final result = ["label1", "label2", 'label3', 'label4'].fold('', (p0, p1) => '$p0 $p1').add(element: ',');
    print(result);

    final result2 = ["label1", "label2", 'label3', 'label4'].fold('', (p0, p1) => '$p0 $p1') + ',';
    print(result2);
  });

  test('remove prefix', () {
    final result = "EnumFileDisplayType".removePrefix('Enum');
    print(result);
  });
}

extension StringExtensions on String {
  String plus({Object? element}) => padRight(length + 1, element?.toString() ?? '');
  String add({Object? element}) => this + (element?.toString() ?? '');
}
