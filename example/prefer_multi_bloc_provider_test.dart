// ignore_for_file: prefer_underscore_for_unused_callback_parameters, avoid_dynamic, add_cubit_suffix_rule

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final provider = BlocProvider<BlocA>(
  create: (context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (context) => BlocB(BlocA()),
    child: BlocProvider<BlocC>(
      create: (context) => BlocC(),
      child: Container(),
    ),
  ),
);

class BlocA extends Cubit<int> {
  BlocA() : super(0);
}

class BlocB extends Cubit<int> {
  final BlocA blocA;

  BlocB(this.blocA) : super(0);
}

class BlocC extends Cubit<int> {
  BlocC() : super(0);
}
