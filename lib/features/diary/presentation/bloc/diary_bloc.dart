import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';

part 'diary_event.dart';

part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final GetTrackedDayUsecase _getDayTrackedUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final GetIntakeUsecase _getIntakeUsecase;

  DateTime currentDay = DateTime.now();

  DiaryBloc(this._getDayTrackedUsecase, this._getConfigUsecase, this._getIntakeUsecase)
      : super(DiaryInitial()) {
    on<LoadDiaryYearEvent>((event, emit) async {
      emit(DiaryLoadingState());

      final usesImperialUnits =
          (await _getConfigUsecase.getConfig()).usesImperialUnits;

      currentDay = DateTime.now();
      const yearDuration = Duration(days: 356);

      final trackedDays = await _getDayTrackedUsecase.getTrackedDaysByRange(
          currentDay.subtract(yearDuration), currentDay.add(yearDuration));

      final trackedDaysMap = {
        for (var trackedDay in trackedDays)
          trackedDay.day.toParsedDay(): trackedDay
      };

      // Load intake data for all days in the range
      final intakeDataMap = <String, List<IntakeEntity>>{};
      final startDate = currentDay.subtract(yearDuration);
      final endDate = currentDay.add(yearDuration);
      
      for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        final dayKey = date.toParsedDay();
        final allIntakes = <IntakeEntity>[];
        
        // Get all intake types for this day
        allIntakes.addAll(await _getIntakeUsecase.getBreakfastIntakeByDay(date));
        allIntakes.addAll(await _getIntakeUsecase.getLunchIntakeByDay(date));
        allIntakes.addAll(await _getIntakeUsecase.getDinnerIntakeByDay(date));
        allIntakes.addAll(await _getIntakeUsecase.getSnackIntakeByDay(date));
        
        intakeDataMap[dayKey] = allIntakes;
      }

      emit(DiaryLoadedState(trackedDaysMap, usesImperialUnits, intakeDataMap));
    });
  }

  void updateHomePage() {
    locator<HomeBloc>().add(const LoadItemsEvent());
  }
}
