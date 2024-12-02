import 'package:flutter_test/flutter_test.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

void main() {
  group('groupBy', () {
    test('empty list', () {
      final list = <int>[];
      final result = list.groupBy((e) => e);
      expect(result, {});
    });

    test('single element list', () {
      final list = [1];
      final result = list.groupBy((e) => e);
      expect(result, {
        1: [1]
      });
    });

    test('multiple elements with same key', () {
      final list = [1, 1, 1];
      final result = list.groupBy((e) => e);
      expect(result, {
        1: [1, 1, 1]
      });
    });

    test('multiple elements with different keys', () {
      final list = [1, 2, 3];
      final result = list.groupBy((e) => e);
      expect(result, {
        1: [1],
        2: [2],
        3: [3]
      });
    });

    test('selector function that returns null', () {
      final list = [1, 2, 3];
      final result = list.groupBy((e) => null);
      expect(result, {
        null: [1, 2, 3]
      });
    });
  });
}
