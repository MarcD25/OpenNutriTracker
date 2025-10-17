import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_calendar_service.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

// Events
abstract class DiaryCalendarEvent extends Equatable {
  const DiaryCalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckinDaysEvent extends DiaryCalendarEvent {
  final DateTime month;

  const LoadCheckinDaysEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class UpdateCheckinFrequencyEvent extends DiaryCalendarEvent {
  final CheckinFrequency frequency;

  const UpdateCheckinFrequencyEvent(this.frequency);

  @override
  List<Object?> get props => [frequency];
}

// States
abstract class DiaryCalendarState extends Equatable {
  const DiaryCalendarState();

  @override
  List<Object?> get props => [];
}

class DiaryCalendarInitial extends DiaryCalendarState {}

class DiaryCalendarLoading extends DiaryCalendarState {}

class DiaryCalendarLoaded extends DiaryCalendarState {
  final Map<DateTime, bool> checkinDays;
  final Map<DateTime, bool> weightEntryDays;
  final CheckinFrequency currentFrequency;

  const DiaryCalendarLoaded({
    required this.checkinDays,
    required this.weightEntryDays,
    required this.currentFrequency,
  });

  @override
  List<Object?> get props => [checkinDays, weightEntryDays, currentFrequency];
}

class DiaryCalendarError extends DiaryCalendarState {
  final String message;

  const DiaryCalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DiaryCalendarBloc extends Bloc<DiaryCalendarEvent, DiaryCalendarState> {
  final WeightCheckinCalendarService _calendarService;

  DiaryCalendarBloc(this._calendarService) : super(DiaryCalendarInitial()) {
    on<LoadCheckinDaysEvent>(_onLoadCheckinDays);
    on<UpdateCheckinFrequencyEvent>(_onUpdateCheckinFrequency);
  }

  Future<void> _onLoadCheckinDays(
    LoadCheckinDaysEvent event,
    Emitter<DiaryCalendarState> emit,
  ) async {
    try {
      emit(DiaryCalendarLoading());
      
      final checkinDays = await _calendarService.getCheckinDaysForMonth(event.month);
      final currentFrequency = await _calendarService.getCheckinFrequency();
      
      // Load weight entry information for the month
      final weightEntryDays = <DateTime, bool>{};
      final lastDayOfMonth = DateTime(event.month.year, event.month.month + 1, 0);
      
      for (int day = 1; day <= lastDayOfMonth.day; day++) {
        final currentDate = DateTime(event.month.year, event.month.month, day);
        final hasEntry = await _calendarService.hasWeightEntryForDate(currentDate);
        weightEntryDays[currentDate] = hasEntry;
      }
      
      // Debug logging
      print('DiaryCalendarBloc: Loaded ${checkinDays.length} check-in days for ${event.month.month}/${event.month.year}');
      print('DiaryCalendarBloc: Check-in frequency: $currentFrequency');
      checkinDays.forEach((date, isCheckin) {
        if (isCheckin) {
          final hasEntry = weightEntryDays[date] ?? false;
          print('DiaryCalendarBloc: Check-in day: ${date.day}/${date.month}/${date.year} (has entry: $hasEntry)');
        }
      });
      
      emit(DiaryCalendarLoaded(
        checkinDays: checkinDays,
        weightEntryDays: weightEntryDays,
        currentFrequency: currentFrequency,
      ));
    } catch (e) {
      print('DiaryCalendarBloc: Error loading check-in days: $e');
      emit(DiaryCalendarError('Failed to load check-in days: $e'));
    }
  }

  Future<void> _onUpdateCheckinFrequency(
    UpdateCheckinFrequencyEvent event,
    Emitter<DiaryCalendarState> emit,
  ) async {
    try {
      await _calendarService.setCheckinFrequency(event.frequency);
      
      // Reload the current month with new frequency
      if (state is DiaryCalendarLoaded) {
        final currentState = state as DiaryCalendarLoaded;
        // Assume we're looking at the current month, but in a real implementation
        // you'd want to track which month is currently being viewed
        final currentMonth = DateTime.now();
        add(LoadCheckinDaysEvent(currentMonth));
      }
    } catch (e) {
      emit(DiaryCalendarError('Failed to update check-in frequency: $e'));
    }
  }
}