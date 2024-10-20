// ignore_for_file: unused_import

import 'package:my_custom_lints/src/rules/prefer_enum_with_sentinel_value_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // test('Enum without sentinel triggers lint', () {
  //   final rule = PreferEnumWithSentinelValueRule();
  //   final source = '''
  //   enum ConnectionState {
  //     connecting,
  //     connected,
  //     disconnected,
  //   }
  //   ''';
  //   var lints = analyze(source, rule);
  //   expect(lints, hasLength(1));
  // });

  // test('Enum with sentinel does not trigger lint', () {
  //   final rule = PreferEnumWithSentinelValueRule();
  //   final source = '''
  //   enum ConnectionState {
  //     uninitialized,
  //     connecting,
  //     connected,
  //     disconnected,
  //   }
  //   ''';
  //   var lints = analyze(source, rule);
  //   expect(lints, isEmpty);
  // });
}
