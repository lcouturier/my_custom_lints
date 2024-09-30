// ignore_for_file: unused_parameter, prefer_named_bool_parameters, boolean_prefixes, unused_local_variable
void fn(bool flag) {
  final another = [
    ...<String>[], // LINT
    if (flag) ...[
      'some',
    ],
  ];
}

void fn2(bool flag) {
  final another = [
    ...<String>['some', 'elements'],
  ];
}
