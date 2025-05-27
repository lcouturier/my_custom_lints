// ignore_for_file: avoid_returning_value_from_cubit_methods, avoid_numeric_literals

import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  Future<void> increment() async {
    emit(state + 1);
    await Future.delayed(const Duration(seconds: 3));
    emit(state - 1); // LINT: Avoid emitting an event after an await point without checking 'isClosed'.
    if (!isClosed) {
      emit(state - 1);
    }

    await Future.delayed(const Duration(seconds: 3)).then((_) {
      emit(state + 1);
    });
  }
}
