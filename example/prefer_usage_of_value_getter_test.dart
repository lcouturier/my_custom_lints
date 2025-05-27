// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

void fn(String Function() display) {
  print(display());
}

class MyClass {
  final String name;
  final ValueGetter<String> onDisplayedName;

  MyClass({required this.name, required this.onDisplayedName});

  void fn(String? Function()? display) {
    print(display?.call());
  }
}
