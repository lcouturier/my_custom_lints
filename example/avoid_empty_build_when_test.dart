import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWidgetCubit, int>(
      builder: (_, state) {
        return Text(state.toString());
      },
    );
  }
}

class MyWidgetCubit extends Cubit<int> {
  MyWidgetCubit() : super(0);
}
