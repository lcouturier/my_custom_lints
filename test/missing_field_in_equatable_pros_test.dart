// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   test('Test equatable props check', () async {
//     final lintResult = await testCustomLintRule('equatable_props_check.dart', source: '''
//       import 'package:equatable/equatable.dart';
      
//       class TestClass extends Equatable {
//         final int field1;
//         final String field2;
        
//         TestClass(this.field1, this.field2);
        
//         @override
//         List<Object?> get props => [field1]; // Missing field2
//       }
//     ''');

//     expect(lintResult.errors, isNotEmpty);
//     expect(lintResult.errors.first.message, contains('The following fields are missing from the props getter: field2'));
//   });
// }
