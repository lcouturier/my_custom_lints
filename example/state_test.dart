// ignore_for_file: unused_parameter
import 'package:equatable/equatable.dart';

sealed class BaseState extends Equatable {
  BaseState();

  @override
  List<Object?> get props => [];

  bool get isLoading => this is LoadingState;
  bool get isLoaded => this is LoadedState;
  bool get isError => this is ErrorState;
}

class LoadingState extends BaseState {}

class LoadedState extends BaseState {
  final int id;
  final String data;

  LoadedState({required this.id, required this.data});
}

class ErrorState extends BaseState {
  final String error;

  ErrorState({required this.error});
}
