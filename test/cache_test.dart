import 'package:flutter_test/flutter_test.dart';
import 'package:my_custom_lints/src/common/extensions.dart';

void main() {
  group('cache', () {
    test('should return the same value for the same key', () {
      final cache = (int a) => a * 2;
      final cached = cache.cache();
      expect(cached(2), equals(4));
      expect(cached(2), equals(4));
    });

    test('should return different values for different keys', () {
      final cache = (int a) => a * 2;
      final cached = cache.cache();
      expect(cached(2), equals(4));
      expect(cached(3), equals(6));
    });

    test('should cache the function call', () {
      var callCount = 0;
      final cache = (int a) {
        callCount++;
        return a * 2;
      };
      final cached = cache.cache();
      expect(cached(2), equals(4));
      expect(cached(2), equals(4));
      expect(callCount, equals(1));
    });
  });
}
