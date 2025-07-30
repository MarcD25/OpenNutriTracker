import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/repository/intake_repository.dart';
import 'package:opennutritracker/core/data/repository/tracked_day_repository.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';

class ChatDiaryDataUsecase {
  final IntakeRepository _intakeRepository;
  final TrackedDayRepository _trackedDayRepository;
  final Logger _log = Logger('ChatDiaryDataUsecase');

  ChatDiaryDataUsecase(this._intakeRepository, this._trackedDayRepository);

  /// Gets all food entries for a specific date
  Future<List<IntakeEntity>> getFoodEntriesForDate(DateTime date) async {
    try {
      final breakfastEntries = await _intakeRepository.getIntakeByDateAndType(
        IntakeTypeEntity.breakfast,
        date,
      );
      final lunchEntries = await _intakeRepository.getIntakeByDateAndType(
        IntakeTypeEntity.lunch,
        date,
      );
      final dinnerEntries = await _intakeRepository.getIntakeByDateAndType(
        IntakeTypeEntity.dinner,
        date,
      );
      final snackEntries = await _intakeRepository.getIntakeByDateAndType(
        IntakeTypeEntity.snack,
        date,
      );

      return [...breakfastEntries, ...lunchEntries, ...dinnerEntries, ...snackEntries];
    } catch (e) {
      _log.severe('Error getting food entries for date: $e');
      return [];
    }
  }

  /// Gets tracked day data for a specific date
  Future<TrackedDayEntity?> getTrackedDayForDate(DateTime date) async {
    try {
      return await _trackedDayRepository.getTrackedDay(date);
    } catch (e) {
      _log.severe('Error getting tracked day for date: $e');
      return null;
    }
  }

  /// Gets tracked day data for a date range
  Future<List<TrackedDayEntity>> getTrackedDaysForRange(DateTime start, DateTime end) async {
    try {
      return await _trackedDayRepository.getTrackedDayByRange(start, end);
    } catch (e) {
      _log.severe('Error getting tracked days for range: $e');
      return [];
    }
  }

  /// Gets recent food entries (last 7 days)
  Future<List<IntakeEntity>> getRecentFoodEntries({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final List<IntakeEntity> allEntries = [];

      for (int i = 0; i < days; i++) {
        final date = endDate.subtract(Duration(days: i));
        final entries = await getFoodEntriesForDate(date);
        allEntries.addAll(entries);
      }

      return allEntries;
    } catch (e) {
      _log.severe('Error getting recent food entries: $e');
      return [];
    }
  }

  /// Gets food entries for a specific meal type on a specific date
  Future<List<IntakeEntity>> getFoodEntriesForMealType(DateTime date, IntakeTypeEntity mealType) async {
    try {
      return await _intakeRepository.getIntakeByDateAndType(mealType, date);
    } catch (e) {
      _log.severe('Error getting food entries for meal type: $e');
      return [];
    }
  }

  /// Formats food entries into a readable string for the AI
  String formatFoodEntriesForAI(List<IntakeEntity> entries) {
    if (entries.isEmpty) {
      return 'No food entries found for this period.';
    }

    final buffer = StringBuffer();
    buffer.writeln('**Food Entries:**');

    // Group by date
    final entriesByDate = <DateTime, List<IntakeEntity>>{};
    for (final entry in entries) {
      final date = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }

    // Sort dates
    final sortedDates = entriesByDate.keys.toList()..sort();

    for (final date in sortedDates) {
      final dayEntries = entriesByDate[date]!;
      buffer.writeln('\n**${_formatDate(date)}:**');

      // Group by meal type
      final entriesByMealType = <IntakeTypeEntity, List<IntakeEntity>>{};
      for (final entry in dayEntries) {
        entriesByMealType.putIfAbsent(entry.type, () => []).add(entry);
      }

      for (final mealType in entriesByMealType.keys) {
        final mealEntries = entriesByMealType[mealType]!;
        buffer.writeln('\n*${_formatMealType(mealType)}:*');
        
        for (final entry in mealEntries) {
          final meal = entry.meal;
          final nutriments = meal.nutriments;
          
          // Calculate actual nutrition based on amount consumed
          final actualCalories = ((nutriments.energyKcal100 ?? 0) / 100) * entry.amount;
          final actualProtein = ((nutriments.proteins100 ?? 0) / 100) * entry.amount;
          final actualCarbs = ((nutriments.carbohydrates100 ?? 0) / 100) * entry.amount;
          final actualFat = ((nutriments.fat100 ?? 0) / 100) * entry.amount;

          buffer.writeln('- ${meal.name} (${entry.amount} ${entry.unit})');
          buffer.writeln('  - Calories: ${actualCalories.toStringAsFixed(1)} kcal');
          buffer.writeln('  - Protein: ${actualProtein.toStringAsFixed(1)}g');
          buffer.writeln('  - Carbs: ${actualCarbs.toStringAsFixed(1)}g');
          buffer.writeln('  - Fat: ${actualFat.toStringAsFixed(1)}g');
        }
      }
    }

    return buffer.toString();
  }

  /// Formats tracked day data into a readable string for the AI
  String formatTrackedDayForAI(TrackedDayEntity? trackedDay) {
    if (trackedDay == null) {
      return 'No tracked day data available.';
    }

    final buffer = StringBuffer();
    buffer.writeln('**Daily Progress Summary:**');
    buffer.writeln('**Date:** ${_formatDate(trackedDay.day)}');
    buffer.writeln('\n**Calories:**');
    buffer.writeln('- Goal: ${trackedDay.calorieGoal.toStringAsFixed(1)} kcal');
    buffer.writeln('- Tracked: ${trackedDay.caloriesTracked.toStringAsFixed(1)} kcal');
    buffer.writeln('- Remaining: ${(trackedDay.calorieGoal - trackedDay.caloriesTracked).toStringAsFixed(1)} kcal');
    buffer.writeln('- Progress: ${((trackedDay.caloriesTracked / trackedDay.calorieGoal) * 100).toStringAsFixed(1)}%');

    if (trackedDay.proteinGoal != null && trackedDay.proteinTracked != null) {
      buffer.writeln('\n**Protein:**');
      buffer.writeln('- Goal: ${trackedDay.proteinGoal!.toStringAsFixed(1)}g');
      buffer.writeln('- Tracked: ${trackedDay.proteinTracked!.toStringAsFixed(1)}g');
      buffer.writeln('- Remaining: ${(trackedDay.proteinGoal! - trackedDay.proteinTracked!).toStringAsFixed(1)}g');
    }

    if (trackedDay.carbsGoal != null && trackedDay.carbsTracked != null) {
      buffer.writeln('\n**Carbohydrates:**');
      buffer.writeln('- Goal: ${trackedDay.carbsGoal!.toStringAsFixed(1)}g');
      buffer.writeln('- Tracked: ${trackedDay.carbsTracked!.toStringAsFixed(1)}g');
      buffer.writeln('- Remaining: ${(trackedDay.carbsGoal! - trackedDay.carbsTracked!).toStringAsFixed(1)}g');
    }

    if (trackedDay.fatGoal != null && trackedDay.fatTracked != null) {
      buffer.writeln('\n**Fat:**');
      buffer.writeln('- Goal: ${trackedDay.fatGoal!.toStringAsFixed(1)}g');
      buffer.writeln('- Tracked: ${trackedDay.fatTracked!.toStringAsFixed(1)}g');
      buffer.writeln('- Remaining: ${(trackedDay.fatGoal! - trackedDay.fatTracked!).toStringAsFixed(1)}g');
    }

    return buffer.toString();
  }

  /// Formats multiple tracked days into a readable string for the AI
  String formatTrackedDaysForAI(List<TrackedDayEntity> trackedDays) {
    if (trackedDays.isEmpty) {
      return 'No tracked day data available for this period.';
    }

    final buffer = StringBuffer();
    buffer.writeln('**Progress Summary (${trackedDays.length} days):**');

    // Sort by date
    trackedDays.sort((a, b) => a.day.compareTo(b.day));

    for (final trackedDay in trackedDays) {
      buffer.writeln('\n**${_formatDate(trackedDay.day)}:**');
      buffer.writeln('- Calories: ${trackedDay.caloriesTracked.toStringAsFixed(1)}/${trackedDay.calorieGoal.toStringAsFixed(1)} kcal (${((trackedDay.caloriesTracked / trackedDay.calorieGoal) * 100).toStringAsFixed(1)}%)');
      
      if (trackedDay.proteinTracked != null && trackedDay.proteinGoal != null) {
        buffer.writeln('- Protein: ${trackedDay.proteinTracked!.toStringAsFixed(1)}/${trackedDay.proteinGoal!.toStringAsFixed(1)}g');
      }
      if (trackedDay.carbsTracked != null && trackedDay.carbsGoal != null) {
        buffer.writeln('- Carbs: ${trackedDay.carbsTracked!.toStringAsFixed(1)}/${trackedDay.carbsGoal!.toStringAsFixed(1)}g');
      }
      if (trackedDay.fatTracked != null && trackedDay.fatGoal != null) {
        buffer.writeln('- Fat: ${trackedDay.fatTracked!.toStringAsFixed(1)}/${trackedDay.fatGoal!.toStringAsFixed(1)}g');
      }
    }

    // Calculate averages
    final totalCalories = trackedDays.fold(0.0, (sum, day) => sum + day.caloriesTracked);
    final totalCalorieGoal = trackedDays.fold(0.0, (sum, day) => sum + day.calorieGoal);
    final avgCalories = totalCalories / trackedDays.length;
    final avgCalorieGoal = totalCalorieGoal / trackedDays.length;

    buffer.writeln('\n**Averages:**');
    buffer.writeln('- Average daily calories: ${avgCalories.toStringAsFixed(1)} kcal');
    buffer.writeln('- Average daily goal: ${avgCalorieGoal.toStringAsFixed(1)} kcal');
    buffer.writeln('- Average progress: ${((avgCalories / avgCalorieGoal) * 100).toStringAsFixed(1)}%');

    return buffer.toString();
  }

  /// Gets comprehensive diary data for the AI
  Future<String> getDiaryDataForAI({
    DateTime? specificDate,
    int daysBack = 7,
    bool includeFoodEntries = true,
    bool includeProgress = true,
  }) async {
    try {
      final buffer = StringBuffer();
      final targetDate = specificDate ?? DateTime.now();

      if (includeFoodEntries) {
        final foodEntries = await getFoodEntriesForDate(targetDate);
        buffer.writeln(formatFoodEntriesForAI(foodEntries));
        buffer.writeln('\n---\n');
      }

      if (includeProgress) {
        final trackedDay = await getTrackedDayForDate(targetDate);
        buffer.writeln(formatTrackedDayForAI(trackedDay));
      }

      return buffer.toString();
    } catch (e) {
      _log.severe('Error getting diary data for AI: $e');
      return 'Unable to retrieve diary data at this time.';
    }
  }

  /// Gets comprehensive diary data for a date range
  Future<String> getDiaryDataForRange(DateTime start, DateTime end) async {
    try {
      final buffer = StringBuffer();
      
      // Get tracked days for the range
      final trackedDays = await getTrackedDaysForRange(start, end);
      buffer.writeln(formatTrackedDaysForAI(trackedDays));
      buffer.writeln('\n---\n');

      // Get food entries for each day
      final allFoodEntries = <IntakeEntity>[];
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final date = start.add(Duration(days: i));
        final entries = await getFoodEntriesForDate(date);
        allFoodEntries.addAll(entries);
      }

      if (allFoodEntries.isNotEmpty) {
        buffer.writeln(formatFoodEntriesForAI(allFoodEntries));
      }

      return buffer.toString();
    } catch (e) {
      _log.severe('Error getting diary data for range: $e');
      return 'Unable to retrieve diary data for this period.';
    }
  }

  /// Gets recent progress summary
  Future<String> getRecentProgressSummary({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      final trackedDays = await getTrackedDaysForRange(startDate, endDate);
      
      return formatTrackedDaysForAI(trackedDays);
    } catch (e) {
      _log.severe('Error getting recent progress summary: $e');
      return 'Unable to retrieve recent progress data.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatMealType(IntakeTypeEntity mealType) {
    switch (mealType) {
      case IntakeTypeEntity.breakfast:
        return 'Breakfast';
      case IntakeTypeEntity.lunch:
        return 'Lunch';
      case IntakeTypeEntity.dinner:
        return 'Dinner';
      case IntakeTypeEntity.snack:
        return 'Snack';
    }
  }
} 