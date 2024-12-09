// ignore_for_file: unused_local_variable

void fnBad() {
  final Set<String>? localSet = <String>{};

  final collection = [
    if (localSet != null)
      ...localSet, // LINT: Prefer null-aware spread (...?) instead of checking for a potential null value.
    ...localSet != null
        ? localSet
        : <String>{}, // LINT: Prefer null-aware spread (...?) with the then branch expression.
    ...localSet ?? {}, // LINT: Prefer null-aware spread (...?) instead of if-null (??).
  ];
}

void fnGood() {
  final Set<String>? localSet = <String>{};

  final collection = [
    ...?localSet,
    ...?localSet,
    ...?localSet,
  ];
}
