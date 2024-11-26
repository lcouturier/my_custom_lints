// ignore_for_file: add_cubit_suffix_rule, unused_local_variable, avoid_banned_usage, avoid_nullable_boolean, prefer_named_bool_parameters
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage();

  void callback(BuildContext context) {
    final value = BlocProvider.of<BlocA>(context);
  }

  @override
  Widget build(BuildContext context) {
    final value = BlocProvider.of<BlocA>(context, listen: true);
    return Scaffold(
      body: Checkbox(
          value: true,
          onChanged: (value) {
            if (value ?? false) {
              BlocProvider.of<BlocA>(context).onChanged(value);
            }
          }),
    );
  }
}

class BlocA extends Cubit<int> {
  BlocA() : super(0);

  void onChanged(bool? value) {
    print(value);
  }
}
