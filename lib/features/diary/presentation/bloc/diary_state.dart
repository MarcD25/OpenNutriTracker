part of 'diary_bloc.dart';

abstract class DiaryState extends Equatable {
  const DiaryState();
}

class DiaryInitial extends DiaryState {
  @override
  List<Object> get props => [];
}

class DiaryLoadingState extends DiaryState {
  @override
  List<Object?> get props => [];
}

class DiaryLoadedState extends DiaryState {
  final Map<String, TrackedDayEntity> trackedDayMap;
  final bool usesImperialUnits;
  final Map<String, List<IntakeEntity>> intakeDataMap;

  const DiaryLoadedState(this.trackedDayMap, this.usesImperialUnits, this.intakeDataMap);

  @override
  List<Object?> get props => [trackedDayMap, usesImperialUnits, intakeDataMap];
}
