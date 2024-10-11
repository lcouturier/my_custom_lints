// ignore_for_file: unused_parameter, boolean_prefixes
import 'package:equatable/equatable.dart';

sealed class BaseState extends Equatable {
  BaseState();

  @override
  List<Object?> get props => [];
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

sealed class OnboardingBackgroundGeolocState extends Equatable {
  const OnboardingBackgroundGeolocState();

  @override
  List<Object?> get props => [];
}

class OnboardingBackgroundGeolocInitial extends OnboardingBackgroundGeolocState {}

class OnboardingBackgroundGeolocAnimationInProgress extends OnboardingBackgroundGeolocState {
  final bool skipPermission;
  final bool skipAnimation;

  const OnboardingBackgroundGeolocAnimationInProgress({required this.skipPermission, required this.skipAnimation});

  @override
  List<Object?> get props => [...super.props, skipPermission, skipAnimation];
}

class OnboardingBackgroundGeolocOver extends OnboardingBackgroundGeolocState {}
