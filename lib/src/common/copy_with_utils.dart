import 'package:analyzer/dart/element/element.dart';
import 'package:my_custom_lints/src/common/utils.dart';

mixin CopyWithMixin {
  String generateCopyWithMethod(String className, List<FieldElement> fields) {
    final fieldParams =
        fields.map((f) => '${f.type}${isNullableType(f.type) ? 'Function()?' : '?'} ${f.name}').join(', ');
    final fieldAssignments = fields.map((f) {
      if (!isNullableType(f.type)) {
        return '${f.name}: ${f.name} ?? this.${f.name},';
      } else {
        return '${f.name}: ${f.name} != null ? ${f.name}() : this.${f.name},';
      }
    }).join('\n    ');

    return '\n    '
        '''
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
