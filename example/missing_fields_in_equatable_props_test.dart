import 'package:equatable/equatable.dart';

class ShowAddCompanionState extends Equatable {
  const ShowAddCompanionState({
    required this.isCompanionAnonymous,
    required this.hasCompanionToggle,
    required this.isConnected,
    this.verifyFirstNameAndLastName = true,
  });

  final bool isCompanionAnonymous;
  final bool hasCompanionToggle;
  final bool isConnected;
  final bool verifyFirstNameAndLastName;

  ShowAddCompanionState.initial() : this(isCompanionAnonymous: false, hasCompanionToggle: false, isConnected: false);

  // ignore: boolean_prefixes
  bool get displayToggle => isCompanionAnonymous && isConnected && hasCompanionToggle && verifyFirstNameAndLastName;

  @override
  List<Object> get props => [isCompanionAnonymous, hasCompanionToggle, verifyFirstNameAndLastName];

  ShowAddCompanionState copyWith({
    bool? isCompanionAnonymous,
    bool? hasCompanionToggle,
    bool? isConnected,
    bool? verifyFirstNameAndLastName,
  }) {
    return ShowAddCompanionState(
      isCompanionAnonymous: isCompanionAnonymous ?? this.isCompanionAnonymous,
      hasCompanionToggle: hasCompanionToggle ?? this.hasCompanionToggle,
      isConnected: isConnected ?? this.isConnected,
      verifyFirstNameAndLastName: verifyFirstNameAndLastName ?? this.verifyFirstNameAndLastName,
    );
  }
}
