import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:opennutritracker/features/weight_checkin/data/data_source/weight_checkin_data_source.dart';
import 'package:opennutritracker/features/weight_checkin/data/dbo/weight_entry_dbo.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_notification_service.dart';
import 'package:opennutritracker/core/domain/service/calculation_cache_service.dart';

class WeightCheckinUsecase {
  final WeightCheckinDataSource _dataSource;
  final WeightCheckinNotificationService _notificationService;
  final Uuid _uuid = const Uuid();
  final CalculationCacheService _cache = CalculationCacheService();

  WeightCheckinUsecase(this._dataSource, this._notificationService);

  /// Records a new weight entry
  Future<void> recordWeightEntry(
    double weight, {
    String? notes,
    double? bodyFatPercentage,
    double? muscleMass,
  }) async {
    final entry = WeightEntryDBO(
      id: _uuid.v4(),
      weightKG: weight,
      timestamp: DateTime.now(),
      notes: notes,
      bodyFatPercentage: bodyFatPercentage,
      muscleMass: muscleMass,
    );

    await _dataSource.saveWeightEntry(entry);
    await _dataSource.updateLastCheckinDate(DateTime.now());
    
    // Clear weight-related caches since data changed
    _clearWeightCaches();
    
    // Schedule next reminder
    final frequency = await getCheckinFrequency();
    await _scheduleNextReminder(frequency);
  }

  /// Gets weight history for the specified number of days
  /// Results are cached for performance optimization.
  Future<List<WeightEntryEntity>> getWeightHistory(int days) async {
    final cacheKey = 'weight_history_$days';
    
    return await _cache.getOrCalculate(
      cacheKey,
      () async {
        final endDate = DateTime.now();
        final startDate = endDate.subtract(Duration(days: days));
        
        final dbos = await _dataSource.getWeightHistory(
          startDate: startDate,
          endDate: endDate,
        );
        
        return dbos.map((dbo) => WeightEntryEntity.fromWeightEntryDBO(dbo)).toList();
      },
      ttl: const Duration(minutes: 10), // Cache for 10 minutes
    );
  }

  /// Gets all weight history
  Future<List<WeightEntryEntity>> getAllWeightHistory() async {
    final dbos = await _dataSource.getWeightHistory();
    return dbos.map((dbo) => WeightEntryEntity.fromWeightEntryDBO(dbo)).toList();
  }

  /// Gets the latest weight entry
  Future<WeightEntryEntity?> getLatestWeightEntry() async {
    final dbo = await _dataSource.getLatestWeightEntry();
    return dbo != null ? WeightEntryEntity.fromWeightEntryDBO(dbo) : null;
  }

  /// Calculates weight trend over the specified number of days
  /// Results are cached for performance optimization.
  Future<WeightTrend> calculateWeightTrend(int days) async {
    final cacheKey = 'weight_trend_$days';
    
    return await _cache.getOrCalculate(
      cacheKey,
      () async {
        final entries = await getWeightHistory(days);
        
        if (entries.length < 2) {
          return WeightTrend(
            trendDirection: WeightTrendDirection.stable,
            averageWeeklyChange: 0.0,
            totalChange: 0.0,
            confidence: WeightTrendConfidence.low,
            dataPoints: entries.length,
          );
        }

        // Sort entries by timestamp (oldest first)
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        final oldestWeight = entries.first.weightKG;
        final newestWeight = entries.last.weightKG;
        final totalChange = newestWeight - oldestWeight;
        
        // Calculate average weekly change
        final daysDifference = entries.last.timestamp.difference(entries.first.timestamp).inDays;
        final weeksDifference = daysDifference / 7.0;
        final averageWeeklyChange = weeksDifference > 0 ? totalChange / weeksDifference : 0.0;
        
        // Determine trend direction
        WeightTrendDirection direction;
        if (totalChange.abs() < 0.1) {
          direction = WeightTrendDirection.stable;
        } else if (totalChange > 0) {
          direction = WeightTrendDirection.increasing;
        } else {
          direction = WeightTrendDirection.decreasing;
        }
        
        // Calculate confidence based on data points and consistency
        WeightTrendConfidence confidence;
        if (entries.length < 3) {
          confidence = WeightTrendConfidence.low;
        } else if (entries.length < 7) {
          confidence = WeightTrendConfidence.medium;
        } else {
          // Check for consistency in trend
          final isConsistent = _isWeightTrendConsistent(entries);
          confidence = isConsistent ? WeightTrendConfidence.high : WeightTrendConfidence.medium;
        }
        
        return WeightTrend(
          trendDirection: direction,
          averageWeeklyChange: averageWeeklyChange,
          totalChange: totalChange,
          confidence: confidence,
          dataPoints: entries.length,
        );
      },
      ttl: const Duration(minutes: 15), // Cache for 15 minutes
    );
  }

  /// Checks if the user should see a check-in reminder
  Future<bool> shouldShowCheckinReminder() async {
    final nextCheckinDate = await _dataSource.getNextCheckinDate();
    if (nextCheckinDate == null) return true; // First time user
    
    return DateTime.now().isAfter(nextCheckinDate);
  }

  /// Sets the check-in frequency
  Future<void> setCheckinFrequency(CheckinFrequency frequency) async {
    await _dataSource.setCheckinFrequency(frequency);
    
    // Schedule next reminder based on new frequency
    await _scheduleNextReminder(frequency);
  }

  /// Schedules the next weight check-in reminder
  Future<void> _scheduleNextReminder(CheckinFrequency frequency) async {
    final nextDate = _calculateNextCheckinDate(frequency);
    
    try {
      await _notificationService.scheduleReminder(
        scheduledDate: nextDate,
        frequency: frequency,
      );
    } catch (e) {
      // If notification scheduling fails, continue without it
      print('Failed to schedule weight check-in reminder: $e');
    }
  }

  /// Calculates the next check-in date based on frequency
  DateTime _calculateNextCheckinDate(CheckinFrequency frequency) {
    final now = DateTime.now();
    
    switch (frequency) {
      case CheckinFrequency.daily:
        return DateTime(now.year, now.month, now.day + 1, 9, 0); // 9 AM next day
      case CheckinFrequency.weekly:
        return DateTime(now.year, now.month, now.day + 7, 9, 0); // 9 AM next week
      case CheckinFrequency.biweekly:
        return DateTime(now.year, now.month, now.day + 14, 9, 0); // 9 AM in 2 weeks
      case CheckinFrequency.monthly:
        return DateTime(now.year, now.month + 1, now.day, 9, 0); // 9 AM next month
    }
  }

  /// Initializes notification service
  Future<void> initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      print('Failed to initialize weight check-in notifications: $e');
    }
  }

  /// Requests notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      return await _notificationService.requestPermissions();
    } catch (e) {
      print('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Gets the current check-in frequency
  Future<CheckinFrequency> getCheckinFrequency() async {
    return await _dataSource.getCheckinFrequency();
  }

  /// Gets the next scheduled check-in date
  Future<DateTime?> getNextCheckinDate() async {
    return await _dataSource.getNextCheckinDate();
  }

  /// Deletes a weight entry
  Future<void> deleteWeightEntry(String id) async {
    await _dataSource.deleteWeightEntry(id);
  }

  /// Validates weight input
  bool isValidWeight(double weight, {bool isKilograms = true}) {
    if (isKilograms) {
      // Valid range: 20kg to 300kg
      return weight >= 20.0 && weight <= 300.0;
    } else {
      // Valid range: 44lbs to 661lbs (converted from kg range)
      return weight >= 44.0 && weight <= 661.0;
    }
  }

  /// Converts weight between units
  double convertWeight(double weight, {required bool fromKgToLbs}) {
    if (fromKgToLbs) {
      return weight * 2.20462;
    } else {
      return weight / 2.20462;
    }
  }

  /// Calculates BMI from weight and height
  double calculateBMI(double weightKG, double heightCM) {
    final heightM = heightCM / 100.0;
    return weightKG / (heightM * heightM);
  }

  /// Initializes default weight check-in settings for new users
  Future<void> initializeDefaultSettings() async {
    try {
      // Check if user already has weight check-in data
      final existingHistory = await getAllWeightHistory();
      final currentFrequency = await getCheckinFrequency();
      
      // If no history exists, set up defaults
      if (existingHistory.isEmpty) {
        print('WeightCheckinUsecase: Initializing default settings for new user');
        
        // Set default frequency to weekly
        await setCheckinFrequency(CheckinFrequency.weekly);
        
        // Add a sample weight entry from a week ago to establish a pattern
        final sampleDate = DateTime.now().subtract(const Duration(days: 7));
        final sampleEntry = WeightEntryDBO(
          id: _uuid.v4(),
          weightKG: 70.0, // Default sample weight
          timestamp: sampleDate,
          notes: 'Initial weight entry',
        );
        
        await _dataSource.saveWeightEntry(sampleEntry);
        await _dataSource.updateLastCheckinDate(sampleDate);
        
        print('WeightCheckinUsecase: Added sample weight entry for ${sampleDate.day}/${sampleDate.month}/${sampleDate.year}');
      }
      
      print('WeightCheckinUsecase: Current check-in frequency: $currentFrequency');
    } catch (e) {
      print('WeightCheckinUsecase: Failed to initialize default settings: $e');
    }
  }

  /// Adds sample weight data for testing calendar highlighting
  Future<void> addSampleWeightData() async {
    try {
      final now = DateTime.now();
      final sampleEntries = [
        // Add entries for the past few weeks to show pattern
        WeightEntryDBO(
          id: _uuid.v4(),
          weightKG: 72.0,
          timestamp: now.subtract(const Duration(days: 21)),
          notes: 'Sample entry 1',
        ),
        WeightEntryDBO(
          id: _uuid.v4(),
          weightKG: 71.5,
          timestamp: now.subtract(const Duration(days: 14)),
          notes: 'Sample entry 2',
        ),
        WeightEntryDBO(
          id: _uuid.v4(),
          weightKG: 71.0,
          timestamp: now.subtract(const Duration(days: 7)),
          notes: 'Sample entry 3',
        ),
      ];

      for (final entry in sampleEntries) {
        await _dataSource.saveWeightEntry(entry);
        print('WeightCheckinUsecase: Added sample weight entry for ${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}');
      }

      // Set the last check-in date to a week ago so today shows as a check-in day
      await _dataSource.updateLastCheckinDate(now.subtract(const Duration(days: 7)));
      
      // Clear caches to refresh data
      _clearWeightCaches();
      
      print('WeightCheckinUsecase: Sample weight data added successfully');
    } catch (e) {
      print('WeightCheckinUsecase: Failed to add sample weight data: $e');
    }
  }

  /// Gets BMI category
  BMICategory getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return BMICategory.underweight;
    } else if (bmi < 25.0) {
      return BMICategory.normal;
    } else if (bmi < 30.0) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }

  /// Checks if weight trend is consistent (helper method)
  bool _isWeightTrendConsistent(List<WeightEntryEntity> entries) {
    if (entries.length < 3) return false;
    
    // Calculate moving averages to smooth out daily fluctuations
    final weights = entries.map((e) => e.weightKG).toList();
    int increasingCount = 0;
    int decreasingCount = 0;
    
    for (int i = 1; i < weights.length; i++) {
      final diff = weights[i] - weights[i - 1];
      if (diff > 0.1) {
        increasingCount++;
      } else if (diff < -0.1) {
        decreasingCount++;
      }
    }
    
    // Trend is consistent if more than 60% of changes are in the same direction
    final totalChanges = increasingCount + decreasingCount;
    if (totalChanges == 0) return true; // All stable
    
    final majorityThreshold = totalChanges * 0.6;
    return increasingCount >= majorityThreshold || decreasingCount >= majorityThreshold;
  }

  /// Clears weight-related caches when data changes
  void _clearWeightCaches() {
    // Clear all weight-related cache entries
    final cacheKeys = [
      'weight_history_7',
      'weight_history_30',
      'weight_history_90',
      'weight_trend_7',
      'weight_trend_30',
      'weight_trend_90',
    ];
    
    for (final key in cacheKeys) {
      _cache.remove(key);
    }
  }

  /// Gets cache statistics for monitoring performance
  String getCacheStats() {
    return _cache.getStats().toString();
  }
}

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}