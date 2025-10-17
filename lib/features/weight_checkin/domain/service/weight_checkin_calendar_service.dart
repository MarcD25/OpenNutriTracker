import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';

/// Service for determining weight check-in calendar indicators
class WeightCheckinCalendarService {
  final WeightCheckinUsecase _weightCheckinUsecase;

  WeightCheckinCalendarService(this._weightCheckinUsecase);

  /// Determines if a given date should show a check-in indicator
  Future<bool> isCheckinDay(DateTime date) async {
    final frequency = await _weightCheckinUsecase.getCheckinFrequency();
    final firstCheckinDate = await _getFirstCheckinDate();
    
    // If no first check-in date is set, use a default starting point that's before the query date
    final startDate = firstCheckinDate ?? DateTime(date.year, date.month, 1);
    
    return _calculateIsCheckinDay(date, frequency, startDate);
  }

  /// Gets a map of dates and their check-in status for a given month
  Future<Map<DateTime, bool>> getCheckinDaysForMonth(DateTime month) async {
    final frequency = await _weightCheckinUsecase.getCheckinFrequency();
    final firstCheckinDate = await _getFirstCheckinDate();
    
    // If no first check-in date is set, use the first day of the month as default
    final startDate = firstCheckinDate ?? DateTime(month.year, month.month, 1);
    
    print('WeightCheckinCalendarService: Getting check-in days for ${month.month}/${month.year}');
    print('WeightCheckinCalendarService: Frequency: $frequency');
    print('WeightCheckinCalendarService: Start date: ${startDate.day}/${startDate.month}/${startDate.year}');
    print('WeightCheckinCalendarService: First check-in date from history: $firstCheckinDate');
    
    final checkinDays = <DateTime, bool>{};
    
    // Get last day of the month
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    // Check each day in the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(month.year, month.month, day);
      final isCheckinDay = _calculateIsCheckinDay(currentDate, frequency, startDate);
      checkinDays[currentDate] = isCheckinDay;
      
      if (isCheckinDay) {
        print('WeightCheckinCalendarService: Check-in day found: ${currentDate.day}/${currentDate.month}/${currentDate.year} (weekday: ${currentDate.weekday})');
      }
    }
    
    print('WeightCheckinCalendarService: Total check-in days found: ${checkinDays.values.where((v) => v).length}');
    
    return checkinDays;
  }

  /// Calculates if a specific date is a check-in day based on frequency and start date
  bool _calculateIsCheckinDay(DateTime date, CheckinFrequency frequency, DateTime startDate) {
    // Only consider dates from start date onwards
    if (date.isBefore(startDate)) {
      return false;
    }
    
    switch (frequency) {
      case CheckinFrequency.daily:
        return true; // Every day is a check-in day
        
      case CheckinFrequency.weekly:
        // Check-in on the same day of week as the start date
        final isCheckinDay = date.weekday == startDate.weekday;
        if (isCheckinDay) {
          print('WeightCheckinCalendarService: Weekly check-in match - Date: ${date.day}/${date.month} (weekday ${date.weekday}) matches start date weekday ${startDate.weekday}');
        }
        return isCheckinDay;
        
      case CheckinFrequency.biweekly:
        // Check-in every 14 days from start date
        final daysDifference = date.difference(startDate).inDays;
        final isCheckinDay = daysDifference >= 0 && daysDifference % 14 == 0;
        if (isCheckinDay) {
          print('WeightCheckinCalendarService: Biweekly check-in match - Date: ${date.day}/${date.month}, days from start: $daysDifference');
        }
        return isCheckinDay;
        
      case CheckinFrequency.monthly:
        // Check-in on the same day of month as the start date
        // Handle edge cases for months with different numbers of days
        final targetDay = startDate.day;
        final lastDayOfMonth = DateTime(date.year, date.month + 1, 0).day;
        
        if (targetDay <= lastDayOfMonth) {
          return date.day == targetDay;
        } else {
          // If target day doesn't exist in this month, use last day of month
          return date.day == lastDayOfMonth;
        }
    }
  }

  /// Gets the first check-in date from user's weight history or settings
  Future<DateTime?> _getFirstCheckinDate() async {
    // Try to get from weight history first
    final allHistory = await _weightCheckinUsecase.getAllWeightHistory();
    if (allHistory.isNotEmpty) {
      // Sort by timestamp and get the earliest entry
      allHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return allHistory.first.timestamp;
    }
    
    // If no history, use a default start date (first day of current month)
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Gets the next scheduled check-in date
  Future<DateTime?> getNextCheckinDate() async {
    return await _weightCheckinUsecase.getNextCheckinDate();
  }

  /// Checks if today is a check-in day
  Future<bool> isTodayCheckinDay() async {
    return await isCheckinDay(DateTime.now());
  }

  /// Gets check-in days for a date range
  Future<List<DateTime>> getCheckinDaysInRange(DateTime startDate, DateTime endDate) async {
    final frequency = await _weightCheckinUsecase.getCheckinFrequency();
    final firstCheckinDate = await _getFirstCheckinDate();
    
    // If no first check-in date is set, use the start of the range
    final checkinStartDate = firstCheckinDate ?? startDate;
    
    final checkinDays = <DateTime>[];
    
    // Iterate through each day in the range
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      if (_calculateIsCheckinDay(currentDate, frequency, checkinStartDate)) {
        checkinDays.add(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return checkinDays;
  }

  /// Gets the current check-in frequency
  Future<CheckinFrequency> getCheckinFrequency() async {
    return await _weightCheckinUsecase.getCheckinFrequency();
  }

  /// Checks if there's a weight entry for a specific date
  Future<bool> hasWeightEntryForDate(DateTime date) async {
    final allHistory = await _weightCheckinUsecase.getAllWeightHistory();
    
    // Check if any entry matches the date (same day)
    return allHistory.any((entry) {
      final entryDate = entry.timestamp;
      return entryDate.year == date.year &&
             entryDate.month == date.month &&
             entryDate.day == date.day;
    });
  }

  /// Sets the check-in frequency
  Future<void> setCheckinFrequency(CheckinFrequency frequency) async {
    await _weightCheckinUsecase.setCheckinFrequency(frequency);
  }
}