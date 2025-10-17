import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../exception/app_exception.dart';
import 'error_logging_service.dart';

/// Service for handling graceful degradation when features fail
class GracefulDegradationService {
  static final GracefulDegradationService _instance = GracefulDegradationService._internal();
  factory GracefulDegradationService() => _instance;
  GracefulDegradationService._internal();

  final ErrorLoggingService _loggingService = ErrorLoggingService();
  final Map<String, bool> _featureStatus = {};

  /// Execute operation with fallback behavior
  Future<T> executeWithFallback<T>({
    required String featureName,
    required Future<T> Function() primaryOperation,
    required T Function() fallbackOperation,
    Duration? timeout,
    bool logFailure = true,
  }) async {
    try {
      // Check if feature is known to be failing
      if (_featureStatus[featureName] == false) {
        if (kDebugMode) {
          debugPrint('Feature $featureName is disabled, using fallback');
        }
        return fallbackOperation();
      }

      // Execute primary operation with timeout
      final future = primaryOperation();
      final result = timeout != null 
          ? await future.timeout(timeout)
          : await future;

      // Mark feature as working
      _featureStatus[featureName] = true;
      return result;

    } catch (error, stackTrace) {
      // Mark feature as failing
      _featureStatus[featureName] = false;

      if (logFailure) {
        await _loggingService.logCustomError(
          'Feature $featureName failed, using fallback',
          errorType: 'GracefulDegradation',
          context: {
            'featureName': featureName,
            'originalError': error.toString(),
          },
          stackTrace: stackTrace,
        );
      }

      if (kDebugMode) {
        debugPrint('Feature $featureName failed: $error. Using fallback.');
      }

      return fallbackOperation();
    }
  }

  /// Execute synchronous operation with fallback
  T executeWithFallbackSync<T>({
    required String featureName,
    required T Function() primaryOperation,
    required T Function() fallbackOperation,
    bool logFailure = true,
  }) {
    try {
      // Check if feature is known to be failing
      if (_featureStatus[featureName] == false) {
        if (kDebugMode) {
          debugPrint('Feature $featureName is disabled, using fallback');
        }
        return fallbackOperation();
      }

      final result = primaryOperation();
      _featureStatus[featureName] = true;
      return result;

    } catch (error, stackTrace) {
      _featureStatus[featureName] = false;

      if (logFailure) {
        _loggingService.logCustomError(
          'Feature $featureName failed, using fallback',
          errorType: 'GracefulDegradation',
          context: {
            'featureName': featureName,
            'originalError': error.toString(),
          },
          stackTrace: stackTrace,
        );
      }

      if (kDebugMode) {
        debugPrint('Feature $featureName failed: $error. Using fallback.');
      }

      return fallbackOperation();
    }
  }

  /// Handle logistics tracking failure gracefully
  Future<void> handleLogisticsFailure(String operation, dynamic error) async {
    await executeWithFallback<void>(
      featureName: 'logistics_tracking',
      primaryOperation: () async {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Logistics failure doesn't affect user experience
        if (kDebugMode) {
          debugPrint('Logistics tracking failed for $operation, continuing normally');
        }
      },
      logFailure: true,
    );
  }

  /// Handle LLM validation failure gracefully
  String handleLLMValidationFailure(String originalResponse, ValidationException error) {
    return executeWithFallbackSync<String>(
      featureName: 'llm_validation',
      primaryOperation: () {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Return original response with warning indicator
        return originalResponse;
      },
      logFailure: true,
    );
  }

  /// Handle BMI calculation failure gracefully
  double handleBMICalculationFailure(double height, double weight, dynamic error) {
    return executeWithFallbackSync<double>(
      featureName: 'bmi_calculation',
      primaryOperation: () {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Use simple BMI calculation as fallback
        if (height > 0 && weight > 0) {
          return weight / (height * height);
        }
        return 25.0; // Default BMI if calculation impossible
      },
      logFailure: true,
    );
  }

  /// Handle calorie calculation failure gracefully
  double handleCalorieCalculationFailure(dynamic error, {double? fallbackValue}) {
    return executeWithFallbackSync<double>(
      featureName: 'calorie_calculation',
      primaryOperation: () {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Use provided fallback or default TDEE
        return fallbackValue ?? 2000.0;
      },
      logFailure: true,
    );
  }

  /// Handle weight check-in failure gracefully
  Future<bool> handleWeightCheckinFailure(dynamic error) async {
    return await executeWithFallback<bool>(
      featureName: 'weight_checkin',
      primaryOperation: () async {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Allow manual weight entry without automated features
        return false; // Indicates automated features are disabled
      },
      logFailure: true,
    );
  }

  /// Handle notification failure gracefully
  Future<bool> handleNotificationFailure(dynamic error) async {
    return await executeWithFallback<bool>(
      featureName: 'notifications',
      primaryOperation: () async {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Continue without notifications
        return false; // Indicates notifications are disabled
      },
      logFailure: true,
    );
  }

  /// Handle table rendering failure gracefully
  Widget handleTableRenderingFailure(String markdownContent, dynamic error) {
    return executeWithFallbackSync<Widget>(
      featureName: 'table_rendering',
      primaryOperation: () {
        throw error; // Re-throw to trigger fallback
      },
      fallbackOperation: () {
        // Return simple text widget as fallback
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            'Table content (simplified view):\n$markdownContent',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      },
      logFailure: true,
    );
  }

  /// Reset feature status (useful for testing or manual recovery)
  void resetFeatureStatus(String featureName) {
    _featureStatus.remove(featureName);
  }

  /// Reset all feature statuses
  void resetAllFeatureStatuses() {
    _featureStatus.clear();
  }

  /// Get current feature status
  Map<String, bool> getFeatureStatuses() {
    return Map.from(_featureStatus);
  }

  /// Check if a feature is currently disabled
  bool isFeatureDisabled(String featureName) {
    return _featureStatus[featureName] == false;
  }

  /// Manually disable a feature
  void disableFeature(String featureName) {
    _featureStatus[featureName] = false;
  }

  /// Manually enable a feature
  void enableFeature(String featureName) {
    _featureStatus[featureName] = true;
  }
}