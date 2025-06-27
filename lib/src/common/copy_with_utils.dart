import 'package:analyzer/dart/element/element.dart';
import 'package:my_custom_lints/src/common/checker.dart';

mixin CopyWithMixin {
  String generateCopyWithMethod(String className, List<FieldElement> fields, {bool isAllNamed = true}) {
    final fieldParams = fields
        .map((f) => '${f.type}${isNullableType(f.type) ? 'Function()?' : '?'} ${f.name}')
        .join(', ');

    final fieldAssignments = fields.map((f) {
      final isNullable = isNullableType(f.type);
      final assignment = isNullable
          ? '${f.name} != null ? ${f.name}() : this.${f.name}'
          : '${f.name} ?? this.${f.name}';
      return isAllNamed ? '${f.name}: $assignment,' : '$assignment,';
    }).join('\n    ');

    return '''
  $className copyWith({
    $fieldParams
  }) {
    return $className(
      $fieldAssignments
    );
  }
''';
  }
}
