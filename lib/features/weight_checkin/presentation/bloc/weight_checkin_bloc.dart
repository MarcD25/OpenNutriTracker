import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';

// Events
abstract class WeightCheckinEvent extends Equatable {
  const WeightCheckinEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightCheckinData extends WeightCheckinEvent {
  final int historyDays;

  const LoadWeightCheckinData({this.historyDays = 30});

  @override
  List<Object?> get props => [historyDays];
}

class RecordWeightEntry extends WeightCheckinEvent {
  final double weight;
  final String? notes;
  final double? bodyFatPercentage;
  final double? muscleMass;

  const RecordWeightEntry({
    required this.weight,
    this.notes,
    this.bodyFatPercentage,
    this.muscleMass,
  });

  @override
  List<Object?> get props => [weight, notes, bodyFatPercentage, muscleMass];
}

class SetCheckinFrequency extends WeightCheckinEvent {
  final CheckinFrequency frequency;

  const SetCheckinFrequency(this.frequency);

  @override
  List<Object?> get props => [frequency];
}

class DeleteWeightEntry extends WeightCheckinEvent {
  final String entryId;

  const DeleteWeightEntry(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

class CheckShouldShowReminder extends WeightCheckinEvent {}

// States
abstract class WeightCheckinState extends Equatable {
  const WeightCheckinState();

  @override
  List<Object?> get props => [];
}

class WeightCheckinInitial extends WeightCheckinState {}

class WeightCheckinLoading extends WeightCheckinState {}

class WeightCheckinLoaded extends WeightCheckinState {
  final List<WeightEntryEntity> weightHistory;
  final WeightEntryEntity? latestEntry;
  final WeightTrend? trend;
  final CheckinFrequency checkinFrequency;
  final DateTime? nextCheckinDate;
  final bool shouldShowReminder;

  const WeightCheckinLoaded({
    required this.weightHistory,
    this.latestEntry,
    this.trend,
    required this.checkinFrequency,
    this.nextCheckinDate,
    required this.shouldShowReminder,
  });

  @override
  List<Object?> get props => [
        weightHistory,
        latestEntry,
        trend,
        checkinFrequency,
        nextCheckinDate,
        shouldShowReminder,
      ];

  WeightCheckinLoaded copyWith({
    List<WeightEntryEntity>? weightHistory,
    WeightEntryEntity? latestEntry,
    WeightTrend? trend,
    CheckinFrequency? checkinFrequency,
    DateTime? nextCheckinDate,
    bool? shouldShowReminder,
  }) {
    return WeightCheckinLoaded(
      weightHistory: weightHistory ?? this.weightHistory,
      latestEntry: latestEntry ?? this.latestEntry,
      trend: trend ?? this.trend,
      checkinFrequency: checkinFrequency ?? this.checkinFrequency,
      nextCheckinDate: nextCheckinDate ?? this.nextCheckinDate,
      shouldShowReminder: shouldShowReminder ?? this.shouldShowReminder,
    );
  }
}

class WeightCheckinError extends WeightCheckinState {
  final String message;

  const WeightCheckinError(this.message);

  @override
  List<Object?> get props => [message];
}

class WeightEntryRecorded extends WeightCheckinState {
  final WeightEntryEntity entry;

  const WeightEntryRecorded(this.entry);

  @override
  List<Object?> get props => [entry];
}

// BLoC
class WeightCheckinBloc extends Bloc<WeightCheckinEvent, WeightCheckinState> {
  final WeightCheckinUsecase _weightCheckinUsecase;

  WeightCheckinBloc(this._weightCheckinUsecase) : super(WeightCheckinInitial()) {
    on<LoadWeightCheckinData>(_onLoadWeightCheckinData);
    on<RecordWeightEntry>(_onRecordWeightEntry);
    on<SetCheckinFrequency>(_onSetCheckinFrequency);
    on<DeleteWeightEntry>(_onDeleteWeightEntry);
    on<CheckShouldShowReminder>(_onCheckShouldShowReminder);
  }

  Future<void> _onLoadWeightCheckinData(
    LoadWeightCheckinData event,
    Emitter<WeightCheckinState> emit,
  ) async {
    try {
      emit(WeightCheckinLoading());

      // Load all data in parallel
      final futures = await Future.wait([
        _weightCheckinUsecase.getWeightHistory(event.historyDays),
        _weightCheckinUsecase.getLatestWeightEntry(),
        _weightCheckinUsecase.getCheckinFrequency(),
        _weightCheckinUsecase.getNextCheckinDate(),
        _weightCheckinUsecase.shouldShowCheckinReminder(),
      ]);

      final weightHistory = futures[0] as List<WeightEntryEntity>;
      final latestEntry = futures[1] as WeightEntryEntity?;
      final checkinFrequency = futures[2] as CheckinFrequency;
      final nextCheckinDate = futures[3] as DateTime?;
      final shouldShowReminder = futures[4] as bool;

      // Calculate trend if we have enough data
      WeightTrend? trend;
      if (weightHistory.length >= 2) {
        trend = await _weightCheckinUsecase.calculateWeightTrend(event.historyDays);
      }

      emit(WeightCheckinLoaded(
        weightHistory: weightHistory,
        latestEntry: latestEntry,
        trend: trend,
        checkinFrequency: checkinFrequency,
        nextCheckinDate: nextCheckinDate,
        shouldShowReminder: shouldShowReminder,
      ));
    } catch (e) {
      emit(WeightCheckinError('Failed to load weight data: ${e.toString()}'));
    }
  }

  Future<void> _onRecordWeightEntry(
    RecordWeightEntry event,
    Emitter<WeightCheckinState> emit,
  ) async {
    try {
      // Validate weight
      if (!_weightCheckinUsecase.isValidWeight(event.weight)) {
        emit(const WeightCheckinError('Invalid weight value'));
        return;
      }

      await _weightCheckinUsecase.recordWeightEntry(
        event.weight,
        notes: event.notes,
        bodyFatPercentage: event.bodyFatPercentage,
        muscleMass: event.muscleMass,
      );

      // Get the latest entry to return
      final latestEntry = await _weightCheckinUsecase.getLatestWeightEntry();
      if (latestEntry != null) {
        emit(WeightEntryRecorded(latestEntry));
      }

      // Reload data to update the UI
      add(const LoadWeightCheckinData());
    } catch (e) {
      emit(WeightCheckinError('Failed to record weight: ${e.toString()}'));
    }
  }

  Future<void> _onSetCheckinFrequency(
    SetCheckinFrequency event,
    Emitter<WeightCheckinState> emit,
  ) async {
    try {
      await _weightCheckinUsecase.setCheckinFrequency(event.frequency);
      
      // Reload data to update the frequency
      add(const LoadWeightCheckinData());
    } catch (e) {
      emit(WeightCheckinError('Failed to set check-in frequency: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteWeightEntry(
    DeleteWeightEntry event,
    Emitter<WeightCheckinState> emit,
  ) async {
    try {
      await _weightCheckinUsecase.deleteWeightEntry(event.entryId);
      
      // Reload data to update the list
      add(const LoadWeightCheckinData());
    } catch (e) {
      emit(WeightCheckinError('Failed to delete weight entry: ${e.toString()}'));
    }
  }

  Future<void> _onCheckShouldShowReminder(
    CheckShouldShowReminder event,
    Emitter<WeightCheckinState> emit,
  ) async {
    try {
      final shouldShow = await _weightCheckinUsecase.shouldShowCheckinReminder();
      
      if (state is WeightCheckinLoaded) {
        final currentState = state as WeightCheckinLoaded;
        emit(currentState.copyWith(shouldShowReminder: shouldShow));
      }
    } catch (e) {
      // Don't emit error for this, just log it
      print('Failed to check reminder status: ${e.toString()}');
    }
  }
}