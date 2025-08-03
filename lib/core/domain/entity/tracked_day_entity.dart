import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class TrackedDayEntity extends Equatable {
  static const maxKcalDifferenceOverGoal = 500;
  static const maxKcalDifferenceUnderGoal = 1000;

  final DateTime day;
  final double calorieGoal;
  final double caloriesTracked;
  final double? carbsGoal;
  final double? carbsTracked;
  final double? fatGoal;
  final double? fatTracked;
  final double? proteinGoal;
  final double? proteinTracked;

  const TrackedDayEntity(
      {required this.day,
      required this.calorieGoal,
      required this.caloriesTracked,
      this.carbsGoal,
      this.carbsTracked,
      this.fatGoal,
      this.fatTracked,
      this.proteinGoal,
      this.proteinTracked});

  factory TrackedDayEntity.fromTrackedDayDBO(TrackedDayDBO trackedDayDBO) {
    return TrackedDayEntity(
        day: trackedDayDBO.day,
        calorieGoal: trackedDayDBO.calorieGoal,
        caloriesTracked: trackedDayDBO.caloriesTracked,
        carbsGoal: trackedDayDBO.carbsGoal,
        carbsTracked: trackedDayDBO.carbsTracked,
        fatGoal: trackedDayDBO.fatGoal,
        fatTracked: trackedDayDBO.fatTracked,
        proteinGoal: trackedDayDBO.proteinGoal,
        proteinTracked: trackedDayDBO.proteinTracked);
  }

  // TODO: make enum class for rating
  Color getCalendarDayRatingColor(BuildContext context) {
    if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  /// Calculates calories dynamically from food entries
  static double calculateCaloriesFromIntakes(List<IntakeEntity> intakes) {
    return intakes.fold<double>(0, (sum, intake) => sum + (intake.totalKcal ?? 0));
  }

  /// Calculates carbs dynamically from food entries
  static double calculateCarbsFromIntakes(List<IntakeEntity> intakes) {
    return intakes.fold<double>(0, (sum, intake) => sum + (intake.totalCarbsGram ?? 0));
  }

  /// Calculates fat dynamically from food entries
  static double calculateFatFromIntakes(List<IntakeEntity> intakes) {
    return intakes.fold<double>(0, (sum, intake) => sum + (intake.totalFatsGram ?? 0));
  }

  /// Calculates protein dynamically from food entries
  static double calculateProteinFromIntakes(List<IntakeEntity> intakes) {
    return intakes.fold<double>(0, (sum, intake) => sum + (intake.totalProteinsGram ?? 0));
  }

  /// Calculates calendar day rating color based on dynamic calorie calculation
  static Color getCalendarDayRatingColorFromIntakes(BuildContext context, double calorieGoal, List<IntakeEntity> intakes) {
    final calculatedCalories = calculateCaloriesFromIntakes(intakes);
    
    if (_hasExceededMaxKcalDifferenceGoalStatic(calorieGoal, calculatedCalories)) {
      return Theme.of(context).colorScheme.primary; // Green for good
    } else {
      return Theme.of(context).colorScheme.error; // Red for over/under eating
    }
  }

  /// Static version of the rating calculation for use with dynamic calories
  static bool _hasExceededMaxKcalDifferenceGoalStatic(double calorieGoal, double calculatedCalories) {
    double difference = calorieGoal - calculatedCalories;

    if (calorieGoal < calculatedCalories) {
      return difference.abs() < maxKcalDifferenceOverGoal;
    } else {
      return difference < maxKcalDifferenceUnderGoal;
    }
  }

  Color getRatingDayTextColor(BuildContext context) {
    if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
      return Theme.of(context).colorScheme.onSecondaryContainer;
    } else {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Color getRatingDayTextBackgroundColor(BuildContext context) {
    if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
      return Theme.of(context).colorScheme.secondaryContainer;
    } else {
      return Theme.of(context).colorScheme.errorContainer;
    }
  }

  bool _hasExceededMaxKcalDifferenceGoal(
      double calorieGoal, caloriesTracked) {
    double difference = calorieGoal - caloriesTracked;

    if (calorieGoal < caloriesTracked) {
      return difference.abs() < maxKcalDifferenceOverGoal;
    } else {
      return difference < maxKcalDifferenceUnderGoal;
    }
  }

  @override
  List<Object?> get props => [
        day,
        calorieGoal,
        caloriesTracked,
        carbsGoal,
        carbsTracked,
        fatGoal,
        fatTracked,
        proteinGoal,
        proteinTracked
      ];
}
