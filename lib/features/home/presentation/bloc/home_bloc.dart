import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
// BMI entity import removed for cleaner home page

import 'package:opennutritracker/core/domain/usecase/add_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';

import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';
// BMI calculation import removed for cleaner home page
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final DeleteIntakeUsecase _deleteIntakeUsecase;
  final UpdateIntakeUsecase _updateIntakeUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUseCase;

  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetUserUsecase _getUserUsecase;
  final WeightCheckinUsecase _weightCheckinUsecase;

  DateTime currentDay = DateTime.now();

  HomeBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._getIntakeUsecase,
      this._deleteIntakeUsecase,
      this._updateIntakeUsecase,
      this._getUserActivityUsecase,
      this._deleteUserActivityUsecase,
      this._addTrackedDayUseCase,
      this._getMacroGoalUsecase,
      this._getUserUsecase,
      this._weightCheckinUsecase)
      : super(HomeInitial()) {
    on<LoadItemsEvent>((event, emit) async {
      emit(HomeLoadingState());

      currentDay = DateTime.now();
      final configData = await _getConfigUsecase.getConfig();
      final usesImperialUnits = configData.usesImperialUnits;
      final showDisclaimerDialog = !configData.hasAcceptedDisclaimer;

      final breakfastIntakeList =
          await _getIntakeUsecase.getTodayBreakfastIntake();
      final totalBreakfastKcal = getTotalKcal(breakfastIntakeList);
      final totalBreakfastCarbs = getTotalCarbs(breakfastIntakeList);
      final totalBreakfastFats = getTotalFats(breakfastIntakeList);
      final totalBreakfastProteins = getTotalProteins(breakfastIntakeList);

      final lunchIntakeList = await _getIntakeUsecase.getTodayLunchIntake();
      final totalLunchKcal = getTotalKcal(lunchIntakeList);
      final totalLunchCarbs = getTotalCarbs(lunchIntakeList);
      final totalLunchFats = getTotalFats(lunchIntakeList);
      final totalLunchProteins = getTotalProteins(lunchIntakeList);

      final dinnerIntakeList = await _getIntakeUsecase.getTodayDinnerIntake();
      final totalDinnerKcal = getTotalKcal(dinnerIntakeList);
      final totalDinnerCarbs = getTotalCarbs(dinnerIntakeList);
      final totalDinnerFats = getTotalFats(dinnerIntakeList);
      final totalDinnerProteins = getTotalProteins(dinnerIntakeList);

      final snackIntakeList = await _getIntakeUsecase.getTodaySnackIntake();
      final totalSnackKcal = getTotalKcal(snackIntakeList);
      final totalSnackCarbs = getTotalCarbs(snackIntakeList);
      final totalSnackFats = getTotalFats(snackIntakeList);
      final totalSnackProteins = getTotalProteins(snackIntakeList);

      final totalKcalIntake = totalBreakfastKcal +
          totalLunchKcal +
          totalDinnerKcal +
          totalSnackKcal;
      final totalCarbsIntake = totalBreakfastCarbs +
          totalLunchCarbs +
          totalDinnerCarbs +
          totalSnackCarbs;
      final totalFatsIntake = totalBreakfastFats +
          totalLunchFats +
          totalDinnerFats +
          totalSnackFats;
      final totalProteinsIntake = totalBreakfastProteins +
          totalLunchProteins +
          totalDinnerProteins +
          totalSnackProteins;

      final userActivities =
          await _getUserActivityUsecase.getTodayUserActivity();
      final totalKcalActivities =
          userActivities.map((activity) => activity.burnedKcal).toList().sum;

      // Get user data for calorie calculations
      final userData = await _getUserUsecase.getUserData();
      
      // Calculate net calorie values for enhanced tracking
      final baseTDEE = CalorieGoalCalc.getTdee(userData);
      final calorieRecommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        userData, 
        totalKcalActivities
      );
      
      // Calculate TDEE with exercise (base TDEE + exercise calories)
      final tdeeWithExercise = baseTDEE + totalKcalActivities;
      
      // Calculate net calories remaining (TDEE + exercise - food consumed)
      final netKcalRemaining = tdeeWithExercise - totalKcalIntake;
      
      // Use BMI-adjusted calorie goal for display
      final totalKcalGoal = calorieRecommendation.netCalories;
      final totalCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatsGoal =
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinsGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      final totalKcalLeft =
          CalorieGoalCalc.getDailyKcalLeft(totalKcalGoal, totalKcalIntake);

      // BMI-related goal reassessment removed for cleaner home page
      
      // Load weight check-in data
      final shouldShowWeightCheckin = await _weightCheckinUsecase.shouldShowCheckinReminder();
      final lastWeightEntry = await _weightCheckinUsecase.getLatestWeightEntry();
      final checkinFrequency = await _weightCheckinUsecase.getCheckinFrequency();
      final nextCheckinDate = await _weightCheckinUsecase.getNextCheckinDate();
      
      // Calculate weight trend if we have enough data
      WeightTrend? weightTrend;
      if (lastWeightEntry != null) {
        try {
          weightTrend = await _weightCheckinUsecase.calculateWeightTrend(30);
        } catch (e) {
          // If trend calculation fails, continue without it
          weightTrend = null;
        }
      }
      
      // BMI tracking removed for cleaner home page

      emit(HomeLoadedState(
          showDisclaimerDialog: showDisclaimerDialog,
          totalKcalDaily: totalKcalGoal,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalIntake,
          totalKcalBurned: totalKcalActivities,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          totalProteinsIntake: totalProteinsIntake,
          breakfastIntakeList: breakfastIntakeList,
          lunchIntakeList: lunchIntakeList,
          dinnerIntakeList: dinnerIntakeList,
          snackIntakeList: snackIntakeList,
          userActivityList: userActivities,
          usesImperialUnits: usesImperialUnits,
          // Net calorie calculation fields
          baseTDEE: baseTDEE,
          tdeeWithExercise: tdeeWithExercise,
          netKcalRemaining: netKcalRemaining,
          // Weight check-in fields
          shouldShowWeightCheckin: shouldShowWeightCheckin,
          lastWeightEntry: lastWeightEntry,
          weightTrend: weightTrend,
          checkinFrequency: checkinFrequency,
          nextCheckinDate: nextCheckinDate));
    });
  }

  double getTotalKcal(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalKcal).toList().sum;

  double getTotalCarbs(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalCarbsGram).toList().sum;

  double getTotalFats(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalFatsGram).toList().sum;

  double getTotalProteins(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalProteinsGram).toList().sum;

  void saveConfigData(bool acceptedDisclaimer) async {
    _addConfigUsecase.setConfigDisclaimer(acceptedDisclaimer);
  }

  Future<void> updateIntakeItem(
      String intakeId, Map<String, dynamic> fields) async {
    final dateTime = DateTime.now();
    // Get old intake values
    final oldIntakeObject = await _getIntakeUsecase.getIntakeById(intakeId);
    assert(oldIntakeObject != null);
    final newIntakeObject =
        await _updateIntakeUsecase.updateIntake(intakeId, fields);
    assert(newIntakeObject != null);
    if (oldIntakeObject!.amount > newIntakeObject!.amount) {
      // Amounts shrunk
      await _addTrackedDayUseCase.removeDayCaloriesTracked(
          dateTime, oldIntakeObject.totalKcal - newIntakeObject.totalKcal);
      await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
          carbsTracked:
              oldIntakeObject.totalCarbsGram - newIntakeObject.totalCarbsGram,
          fatTracked:
              oldIntakeObject.totalFatsGram - newIntakeObject.totalFatsGram,
          proteinTracked: oldIntakeObject.totalProteinsGram -
              newIntakeObject.totalProteinsGram);
    } else if (newIntakeObject.amount > oldIntakeObject.amount) {
      // Amounts gained
      await _addTrackedDayUseCase.addDayCaloriesTracked(
          dateTime, newIntakeObject.totalKcal - oldIntakeObject.totalKcal);
      await _addTrackedDayUseCase.addDayMacrosTracked(dateTime,
          carbsTracked:
              newIntakeObject.totalCarbsGram - oldIntakeObject.totalCarbsGram,
          fatTracked:
              newIntakeObject.totalFatsGram - oldIntakeObject.totalFatsGram,
          proteinTracked: newIntakeObject.totalProteinsGram -
              oldIntakeObject.totalProteinsGram);
    }
    _updateDiaryPage(dateTime);
    
    // Trigger real-time update for net calorie calculation
    add(LoadItemsEvent());
  }

  Future<void> deleteIntakeItem(IntakeEntity intakeEntity) async {
    final dateTime = DateTime.now();
    await _deleteIntakeUsecase.deleteIntake(intakeEntity);
    await _addTrackedDayUseCase.removeDayCaloriesTracked(
        dateTime, intakeEntity.totalKcal);
    await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
        carbsTracked: intakeEntity.totalCarbsGram,
        fatTracked: intakeEntity.totalFatsGram,
        proteinTracked: intakeEntity.totalProteinsGram);

    _updateDiaryPage(dateTime);
    
    // Trigger real-time update for net calorie calculation
    add(LoadItemsEvent());
  }

  Future<void> deleteUserActivityItem(UserActivityEntity activityEntity) async {
    final dateTime = DateTime.now();
    await _deleteUserActivityUsecase.deleteUserActivity(activityEntity);
    _addTrackedDayUseCase.reduceDayCalorieGoal(
        dateTime, activityEntity.burnedKcal);

    final carbsAmount = MacroCalc.getTotalCarbsGoal(activityEntity.burnedKcal);
    final fatAmount = MacroCalc.getTotalFatsGoal(activityEntity.burnedKcal);
    final proteinAmount =
        MacroCalc.getTotalProteinsGoal(activityEntity.burnedKcal);

    _addTrackedDayUseCase.reduceDayMacroGoals(dateTime,
        carbsAmount: carbsAmount,
        fatAmount: fatAmount,
        proteinAmount: proteinAmount);
    _updateDiaryPage(dateTime);
    
    // Trigger real-time update for net calorie calculation
    add(LoadItemsEvent());
  }

  Future<void> _updateDiaryPage(DateTime day) async {
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }

  // BMI-related helper methods removed for cleaner home page focus

  /// Handle weight check-in submission
  Future<void> recordWeightEntry(double weight, String? notes) async {
    try {
      await _weightCheckinUsecase.recordWeightEntry(weight, notes: notes);
      
      // Refresh the home page to update BMI calculations and hide check-in prompt
      add(const LoadItemsEvent());
    } catch (e) {
      // Handle error - could emit an error state or show snackbar
      print('Failed to record weight entry: $e');
      rethrow;
    }
  }

  /// Set weight check-in frequency
  Future<void> setWeightCheckinFrequency(CheckinFrequency frequency) async {
    try {
      await _weightCheckinUsecase.setCheckinFrequency(frequency);
      
      // Refresh to update the next check-in date
      add(const LoadItemsEvent());
    } catch (e) {
      print('Failed to set check-in frequency: $e');
      rethrow;
    }
  }
}
