// ignore_for_file: prefer_named_bool_parameters, boolean_prefixes, avoid_print

void fn1(bool? flag) {
  if (flag == null) {
    print(flag);
  }
}

void fn2(bool flag) {
  print(flag);
}

class Process {
  final bool? flag;

  Process({required this.flag});

  Process copyWith({bool? flag}) {
    // LINT
    return Process(flag: flag ?? this.flag);
  }
}
