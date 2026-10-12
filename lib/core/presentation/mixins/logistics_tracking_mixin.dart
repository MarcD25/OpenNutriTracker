import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/core/domain/usecase/logistics_tracking_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Mixin to provide easy logistics tracking functionality across screens
/// 
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget with LogisticsTrackingMixin {
///   @override
///   Widget build(BuildContext context) {
///     trackScreenView('MyScreen');
///     return Scaffold(...);
///   }
/// }
/// ```
mixin LogisticsTrackingMixin {
  final log = Logger('LogisticsTrackingMixin');
  
  LogisticsTrackingUsecase get _logisticsUsecase => locator<LogisticsTrackingUsecase>();

  /// Track a generic user action
  void trackAction(
    LogisticsEventType type, 
    Map<String, dynamic> data, {
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    try {
      _logisticsUsecase.trackUserAction(type, data, userId: userId, metadata: metadata);
    } catch (e) {
      log.warning('Failed to track action ${type.name}: $e');
    }
  }

  /// Track when a screen is viewed
  void trackScreenView(String screenName, {Map<String, dynamic>? additionalData}) {
    try {
      final data = {
        'screen_name': screenName,
        'view_timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      trackAction(
        LogisticsEventType.screenNavigation,
        data,
        metadata: {
          'action_type': 'screen_view',
          'screen_category': _getScreenCategory(screenName),
        },
      );
    } catch (e) {
      log.warning('Failed to track screen view for $screenName: $e');
    }
  }

  /// Track navigation between screens
  void trackNavigation(String fromScreen, String toScreen, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackNavigation(
        fromScreen, 
        toScreen, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track navigation from $fromScreen to $toScreen: $e');
    }
  }

  /// Track button or UI element interactions
  void trackButtonPress(String buttonName, String screenName, {Map<String, dynamic>? additionalData}) {
    try {
      final data = {
        'button_name': buttonName,
        'screen_name': screenName,
        'interaction_timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      trackAction(
        LogisticsEventType.userAction,
        data,
        metadata: {
          'action_type': 'button_press',
          'ui_interaction': true,
        },
      );
    } catch (e) {
      log.warning('Failed to track button press $buttonName on $screenName: $e');
    }
  }

  /// Track form submissions
  void trackFormSubmission(String formName, String screenName, {
    bool isSuccessful = true,
    Map<String, dynamic>? formData,
    String? errorMessage,
  }) {
    try {
      final data = {
        'form_name': formName,
        'screen_name': screenName,
        'is_successful': isSuccessful,
        'submission_timestamp': DateTime.now().toIso8601String(),
        if (errorMessage != null) 'error_message': errorMessage,
        if (formData != null) 'form_fields': formData.keys.toList(),
      };

      trackAction(
        LogisticsEventType.userAction,
        data,
        metadata: {
          'action_type': 'form_submission',
          'form_interaction': true,
          'success_status': isSuccessful,
        },
      );
    } catch (e) {
      log.warning('Failed to track form submission $formName on $screenName: $e');
    }
  }

  /// Track meal logging actions
  void trackMealLogged(String mealType, int itemCount, double totalCalories, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackMealLogged(
        mealType, 
        itemCount, 
        totalCalories, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track meal logged: $e');
    }
  }

  /// Track exercise logging actions
  void trackExerciseLogged(String exerciseType, Duration duration, double? caloriesBurned, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackExerciseLogged(
        exerciseType, 
        duration, 
        caloriesBurned, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track exercise logged: $e');
    }
  }

  /// Track weight check-in actions
  void trackWeightCheckin(double weight, String unit, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackWeightCheckin(
        weight, 
        unit, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track weight checkin: $e');
    }
  }

  /// Track settings changes
  void trackSettingsChanged(String settingKey, dynamic oldValue, dynamic newValue, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackSettingsChanged(
        settingKey, 
        oldValue, 
        newValue, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track settings changed: $e');
    }
  }

  /// Track goal updates
  void trackGoalUpdated(String goalType, dynamic oldGoal, dynamic newGoal, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackGoalUpdated(
        goalType, 
        oldGoal, 
        newGoal, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track goal updated: $e');
    }
  }

  /// Track chat interactions
  void trackChatInteraction(String message, String response, Duration responseTime, {Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackChatInteraction(
        message, 
        response, 
        responseTime, 
        additionalMetadata: additionalData,
      );
    } catch (e) {
      log.warning('Failed to track chat interaction: $e');
    }
  }

  /// Track search actions
  void trackSearch(String searchTerm, String screenName, int resultCount, {Map<String, dynamic>? additionalData}) {
    try {
      final data = {
        'search_term_length': searchTerm.length,
        'search_term_hash': searchTerm.hashCode.toString(), // Hash for privacy
        'screen_name': screenName,
        'result_count': resultCount,
        'search_timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      trackAction(
        LogisticsEventType.userAction,
        data,
        metadata: {
          'action_type': 'search',
          'search_interaction': true,
        },
      );
    } catch (e) {
      log.warning('Failed to track search on $screenName: $e');
    }
  }

  /// Track error occurrences
  void trackError(String errorType, String errorMessage, String screenName, {
    String? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      final data = {
        'error_type': errorType,
        'error_message': errorMessage,
        'screen_name': screenName,
        'error_timestamp': DateTime.now().toIso8601String(),
        if (stackTrace != null) 'has_stack_trace': true,
        ...?additionalData,
      };

      trackAction(
        LogisticsEventType.userAction,
        data,
        metadata: {
          'action_type': 'error',
          'error_tracking': true,
          'severity': 'error',
        },
      );
    } catch (e) {
      log.warning('Failed to track error on $screenName: $e');
    }
  }

  /// Track performance metrics
  void trackPerformance(String operationName, Duration duration, String screenName, {
    bool isSuccessful = true,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      final data = {
        'operation_name': operationName,
        'duration_ms': duration.inMilliseconds,
        'screen_name': screenName,
        'is_successful': isSuccessful,
        'performance_timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      trackAction(
        LogisticsEventType.userAction,
        data,
        metadata: {
          'action_type': 'performance',
          'performance_tracking': true,
          'operation_category': _getOperationCategory(operationName),
        },
      );
    } catch (e) {
      log.warning('Failed to track performance for $operationName on $screenName: $e');
    }
  }

  /// Track app lifecycle events
  void trackAppLaunched({Map<String, dynamic>? additionalData}) {
    try {
      _logisticsUsecase.trackAppLaunched(additionalMetadata: additionalData);
    } catch (e) {
      log.warning('Failed to track app launched: $e');
    }
  }

  // Private helper methods

  String _getScreenCategory(String screenName) {
    final screenName_ = screenName.toLowerCase();
    
    if (screenName_.contains('home') || screenName_.contains('main')) {
      return 'main';
    } else if (screenName_.contains('chat') || screenName_.contains('ai')) {
      return 'ai_interaction';
    } else if (screenName_.contains('diary') || screenName_.contains('log')) {
      return 'tracking';
    } else if (screenName_.contains('settings') || screenName_.contains('config')) {
      return 'configuration';
    } else if (screenName_.contains('profile') || screenName_.contains('user')) {
      return 'user_management';
    } else if (screenName_.contains('activity') || screenName_.contains('exercise')) {
      return 'fitness';
    } else if (screenName_.contains('meal') || screenName_.contains('food')) {
      return 'nutrition';
    } else {
      return 'other';
    }
  }

  String _getOperationCategory(String operationName) {
    final operationName_ = operationName.toLowerCase();
    
    if (operationName_.contains('api') || operationName_.contains('network')) {
      return 'network';
    } else if (operationName_.contains('database') || operationName_.contains('storage')) {
      return 'storage';
    } else if (operationName_.contains('calculation') || operationName_.contains('compute')) {
      return 'computation';
    } else if (operationName_.contains('ui') || operationName_.contains('render')) {
      return 'ui_rendering';
    } else {
      return 'general';
    }
  }
}

/// Extension to provide logistics tracking for StatefulWidget
extension LogisticsTrackingStatefulWidget on State<StatefulWidget> {
  void trackWidgetLifecycle(String lifecycleEvent) {
    if (this is LogisticsTrackingMixin) {
      final mixin = this as LogisticsTrackingMixin;
      mixin.trackAction(
        LogisticsEventType.userAction,
        {
          'widget_name': widget.runtimeType.toString(),
          'lifecycle_event': lifecycleEvent,
          'timestamp': DateTime.now().toIso8601String(),
        },
        metadata: {
          'action_type': 'widget_lifecycle',
          'widget_tracking': true,
        },
      );
    }
  }
}

/// Extension to provide logistics tracking for StatelessWidget
extension LogisticsTrackingStatelessWidget on StatelessWidget {
  void trackWidgetBuild(BuildContext context) {
    // For StatelessWidget, we can track build events through context
    // This would require a more complex implementation with providers or inherited widgets
    // For now, we'll keep it simple and recommend using the mixin with StatefulWidget
  }
}