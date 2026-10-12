part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  final bool showDisclaimerDialog;
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;
  final List<UserActivityEntity> userActivityList;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final bool usesImperialUnits;
  // Net calorie calculation fields
  final double baseTDEE;
  final double tdeeWithExercise;
  final double netKcalRemaining;
  // Weight check-in fields
  final bool shouldShowWeightCheckin;
  final WeightEntryEntity? lastWeightEntry;
  final WeightTrend? weightTrend;
  final CheckinFrequency checkinFrequency;
  final DateTime? nextCheckinDate;

  const HomeLoadedState({
    required this.showDisclaimerDialog,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
    required this.userActivityList,
    required this.breakfastIntakeList,
    required this.lunchIntakeList,
    required this.dinnerIntakeList,
    required this.snackIntakeList,
    required this.usesImperialUnits,
    required this.baseTDEE,
    required this.tdeeWithExercise,
    required this.netKcalRemaining,
    required this.shouldShowWeightCheckin,
    this.lastWeightEntry,
    this.weightTrend,
    required this.checkinFrequency,
    this.nextCheckinDate,
  });

  @override
  List<Object?> get props => [
        breakfastIntakeList,
        lunchIntakeList,
        dinnerIntakeList,
        snackIntakeList,
        usesImperialUnits,
        baseTDEE,
        tdeeWithExercise,
        netKcalRemaining,
        shouldShowWeightCheckin,
        lastWeightEntry,
        weightTrend,
        checkinFrequency,
        nextCheckinDate,
      ];
}
