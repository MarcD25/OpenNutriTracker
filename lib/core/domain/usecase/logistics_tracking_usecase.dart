import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/logistics_data_source.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';

class LogisticsTrackingUsecase {
  final LogisticsDataSource _logisticsDataSource;
  final log = Logger('LogisticsTrackingUsecase');

  LogisticsTrackingUsecase(this._logisticsDataSource);

  /// Track a user action with specified type and data
  Future<void> trackUserAction(
    LogisticsEventType type, 
    Map<String, dynamic> data, {
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = LogisticsEventEntity(
        id: _generateEventId(),
        eventType: type,
        eventData: _encryptSensitiveData(data),
        timestamp: DateTime.now(),
        userId: userId,
        metadata: metadata,
      );

      await _logisticsDataSource.logUserAction(event);
      log.fine('Successfully tracked user action: ${type.name}');
    } catch (e) {
      log.warning('Failed to track user action ${type.name}: $e');
      // Fail silently to not disrupt user experience
    }
  }

  /// Track chat interaction with message, response, and timing data
  Future<void> trackChatInteraction(
    String message, 
    String response, 
    Duration responseTime, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final sensitiveData = {
        'message_hash': _hashSensitiveContent(message),
        'response_hash': _hashSensitiveContent(response),
        'message_length': message.length,
        'response_length': response.length,
        'response_time_ms': responseTime.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'interaction_type': 'chat',
        'session_id': _generateSessionId(),
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.chatInteraction,
        sensitiveData,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track chat interaction: $e');
    }
  }

  /// Track navigation between screens
  Future<void> trackNavigation(
    String fromScreen, 
    String toScreen, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'from_screen': fromScreen,
        'to_screen': toScreen,
        'timestamp': DateTime.now().toIso8601String(),
        'navigation_duration': DateTime.now().millisecondsSinceEpoch,
      };

      final metadata = {
        'navigation_type': 'screen_change',
        'platform': Platform.operatingSystem,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.screenNavigation,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track navigation: $e');
    }
  }

  /// Track meal logging events
  Future<void> trackMealLogged(
    String mealType,
    int itemCount,
    double totalCalories, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'meal_type': mealType,
        'item_count': itemCount,
        'total_calories': totalCalories,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'action_type': 'meal_logging',
        'nutrition_tracking': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.mealLogged,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track meal logged: $e');
    }
  }

  /// Track exercise logging events
  Future<void> trackExerciseLogged(
    String exerciseType,
    Duration duration,
    double? caloriesBurned, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'exercise_type': exerciseType,
        'duration_minutes': duration.inMinutes,
        'calories_burned': caloriesBurned,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'action_type': 'exercise_logging',
        'fitness_tracking': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.exerciseLogged,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track exercise logged: $e');
    }
  }

  /// Track weight check-in events
  Future<void> trackWeightCheckin(
    double weight,
    String unit, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'weight_value': weight,
        'weight_unit': unit,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'action_type': 'weight_checkin',
        'health_tracking': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.weightCheckin,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track weight checkin: $e');
    }
  }

  /// Track settings changes
  Future<void> trackSettingsChanged(
    String settingKey,
    dynamic oldValue,
    dynamic newValue, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'setting_key': settingKey,
        'old_value': oldValue?.toString(),
        'new_value': newValue?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'action_type': 'settings_change',
        'configuration': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.settingsChanged,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track settings changed: $e');
    }
  }

  /// Track goal updates
  Future<void> trackGoalUpdated(
    String goalType,
    dynamic oldGoal,
    dynamic newGoal, {
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'goal_type': goalType,
        'old_goal': oldGoal?.toString(),
        'new_goal': newGoal?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'action_type': 'goal_update',
        'user_preferences': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.goalUpdated,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track goal updated: $e');
    }
  }

  /// Track app lifecycle events
  Future<void> trackAppLaunched({
    String? userId,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final data = {
        'app_version': 'unknown', // This should be injected from app info
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final metadata = {
        'lifecycle_event': 'app_launched',
        'session_start': true,
        ...?additionalMetadata,
      };

      await trackUserAction(
        LogisticsEventType.appLaunched,
        data,
        userId: userId,
        metadata: metadata,
      );
    } catch (e) {
      log.warning('Failed to track app launched: $e');
    }
  }

  /// Trigger log rotation manually
  Future<void> rotateLogsIfNeeded() async {
    try {
      await _logisticsDataSource.rotateLogsIfNeeded();
      log.info('Log rotation check completed');
    } catch (e) {
      log.warning('Failed to rotate logs: $e');
    }
  }

  /// Get analytics data for performance reviews
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final logs = await _logisticsDataSource.getLogsByDateRange(start, end);
      
      return {
        'total_events': logs.length,
        'date_range': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
        'event_types': _analyzeEventTypes(logs),
        'daily_activity': _analyzeDailyActivity(logs),
        'user_engagement': _analyzeUserEngagement(logs),
      };
    } catch (e) {
      log.warning('Failed to get analytics data: $e');
      return {};
    }
  }

  // Private helper methods

  String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Encrypt sensitive data to protect user privacy
  Map<String, dynamic> _encryptSensitiveData(Map<String, dynamic> data) {
    final encryptedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (_isSensitiveField(entry.key)) {
        // For sensitive fields, store only hashed versions
        encryptedData['${entry.key}_hash'] = _hashSensitiveContent(entry.value.toString());
      } else {
        // Non-sensitive data can be stored as-is
        encryptedData[entry.key] = entry.value;
      }
    }
    
    return encryptedData;
  }

  /// Hash sensitive content for privacy protection
  String _hashSensitiveContent(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Determine if a field contains sensitive information
  bool _isSensitiveField(String fieldName) {
    const sensitiveFields = [
      'message',
      'response',
      'user_input',
      'personal_data',
      'weight_value', // Weight might be considered sensitive
      'goal_details',
    ];
    
    return sensitiveFields.any((field) => 
        fieldName.toLowerCase().contains(field.toLowerCase()));
  }

  Map<String, int> _analyzeEventTypes(List<dynamic> logs) {
    final eventCounts = <String, int>{};
    for (final log in logs) {
      final eventType = log.eventType?.toString() ?? 'unknown';
      eventCounts[eventType] = (eventCounts[eventType] ?? 0) + 1;
    }
    return eventCounts;
  }

  Map<String, int> _analyzeDailyActivity(List<dynamic> logs) {
    final dailyActivity = <String, int>{};
    for (final log in logs) {
      if (log.timestamp != null) {
        final date = DateTime.parse(log.timestamp.toString()).toIso8601String().split('T')[0];
        dailyActivity[date] = (dailyActivity[date] ?? 0) + 1;
      }
    }
    return dailyActivity;
  }

  Map<String, dynamic> _analyzeUserEngagement(List<dynamic> logs) {
    final chatInteractions = logs.where((log) => 
        log.eventType?.toString() == 'chatInteraction').length;
    final mealLogs = logs.where((log) => 
        log.eventType?.toString() == 'mealLogged').length;
    final exerciseLogs = logs.where((log) => 
        log.eventType?.toString() == 'exerciseLogged').length;
    
    return {
      'chat_interactions': chatInteractions,
      'meal_logs': mealLogs,
      'exercise_logs': exerciseLogs,
      'total_user_actions': chatInteractions + mealLogs + exerciseLogs,
    };
  }
}