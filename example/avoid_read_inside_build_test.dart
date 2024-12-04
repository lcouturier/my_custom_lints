// ignore_for_file: add_cubit_suffix_rule, unused_local_variable, avoid_banned_usage, avoid_nullable_boolean, prefer_named_bool_parameters, prefer_underscore_for_unused_callback_parameters, avoid_empty_build_when, avoid_ignoring_return_values
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
    final value = context.read<String>();
    return BlocConsumer<BlocA, int>(
      listener: (context, state) {
        final value = context.watch<String>();
        showAboutDialog(context: context);
      },
      builder: (context, state) {
        return Scaffold(
          body: Checkbox(
              value: true,
              onChanged: (value) {
                if (value ?? false) {
                  context.read<BlocA>().onChanged(value);
                }
              }),
        );
      },
    );
  }

  Future<void> exampleFunction(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.of(context).pushNamed('/new-page');
  }
}

class BlocA extends Cubit<int> {
  BlocA() : super(0);

  void onChanged(bool? value) {
    print(value);
  }
}
