// ignore_for_file: add_cubit_suffix_rule, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage();

  void callback(BuildContext context) {
    // LINT: Avoid using 'watch' outside of the 'build' method. Try rewriting the code to use 'read' instead.
    final value = context.watch<String>();
  }

  @override
  Widget build(BuildContext context) {
    // LINT: Avoid using 'read' inside the 'build' method. Try rewriting the code to use 'watch' instead.
    final value = context.read<int>();
    return Scaffold(
      body: Center(
        child: Text(value.toString()),
      ),
    );
  }
}

class BlocA extends Cubit<int> {
  BlocA() : super(0);
}
