import 'package:flutter/material.dart';
import '../exception/app_exception.dart';
import 'error_logging_service.dart';

/// Service for handling application errors with graceful degradation
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final ErrorLoggingService _loggingService = ErrorLoggingService();

  /// Handle validation errors with appropriate user feedback
  static void handleValidationError(
    BuildContext context,
    ValidationException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    _instance._loggingService.logError(error);

    switch (error.severity) {
      case ValidationSeverity.critical:
        _showCriticalErrorDialog(context, error, onRetry, onDismiss);
        break;
      case ValidationSeverity.error:
        _showErrorDialog(context, error, onRetry, onDismiss);
        break;
      case ValidationSeverity.warning:
        _showWarningSnackBar(context, error);
        break;
      case ValidationSeverity.info:
        _showInfoSnackBar(context, error);
        break;
    }
  }

  /// Handle general application errors
  static void handleAppError(
    BuildContext context,
    AppException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    _instance._loggingService.logError(error);

    if (error is ValidationException) {
      handleValidationError(context, error, onRetry: onRetry, onDismiss: onDismiss);
      return;
    }

    _showErrorDialog(context, error, onRetry, onDismiss);
  }

  /// Handle errors with graceful degradation
  static T handleWithGracefulDegradation<T>(
    T Function() operation,
    T fallbackValue, {
    String? operationName,
    bool logError = true,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      if (logError) {
        _instance._loggingService.logError(
          AppException(
            'Operation failed: ${operationName ?? 'Unknown operation'}',
            originalError: error,
            stackTrace: stackTrace,
          ),
        );
      }
      return fallbackValue;
    }
  }

  /// Handle async operations with graceful degradation
  static Future<T> handleAsyncWithGracefulDegradation<T>(
    Future<T> Function() operation,
    T fallbackValue, {
    String? operationName,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      if (logError) {
        _instance._loggingService.logError(
          AppException(
            'Async operation failed: ${operationName ?? 'Unknown operation'}',
            originalError: error,
            stackTrace: stackTrace,
          ),
        );
      }
      return fallbackValue;
    }
  }

  /// Show critical error dialog that blocks user interaction
  static void _showCriticalErrorDialog(
    BuildContext context,
    ValidationException error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Critical Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...error.issues.map((issue) => Text('• ${_getIssueDescription(issue)}')),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog with retry option
  static void _showErrorDialog(
    BuildContext context,
    AppException error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(_getUserFriendlyMessage(error)),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show warning snackbar
  static void _showWarningSnackBar(BuildContext context, ValidationException error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: error.correctedValue != null
            ? SnackBarAction(
                label: 'Use Suggestion',
                textColor: Colors.white,
                onPressed: () {
                  // Handle correction suggestion
                },
              )
            : null,
      ),
    );
  }

  /// Show info snackbar
  static void _showInfoSnackBar(BuildContext context, ValidationException error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(AppException error) {
    if (error is ValidationException) {
      return _getValidationErrorMessage(error);
    } else if (error is LogisticsException) {
      return 'Unable to track this action. The app will continue to work normally.';
    } else if (error is WeightCheckinException) {
      return 'There was an issue with weight tracking. Please try again or check your input.';
    } else if (error is CalorieCalculationException) {
      return 'Unable to calculate calories accurately. Using default values instead.';
    } else if (error is NotificationException) {
      return 'Notification settings could not be updated. Please check your device settings.';
    }
    
    return error.message.isNotEmpty ? error.message : 'An unexpected error occurred. Please try again.';
  }

  /// Get validation-specific error message
  static String _getValidationErrorMessage(ValidationException error) {
    if (error.issues.contains(ValidationIssue.unrealisticCalories)) {
      return 'The calorie values seem unrealistic. Please double-check your input.';
    } else if (error.issues.contains(ValidationIssue.invalidWeight)) {
      return 'Please enter a valid weight between 30-300 kg (66-660 lbs).';
    } else if (error.issues.contains(ValidationIssue.unrealisticExerciseCalories)) {
      return 'The exercise calories seem too high. Please verify your activity duration and intensity.';
    } else if (error.issues.contains(ValidationIssue.responseTooLarge)) {
      return 'The response was too long and has been shortened for better readability.';
    }
    
    return error.message;
  }

  /// Get description for validation issue
  static String _getIssueDescription(ValidationIssue issue) {
    switch (issue) {
      case ValidationIssue.responseTooLarge:
        return 'Response exceeds maximum length';
      case ValidationIssue.missingNutritionInfo:
        return 'Required nutrition information is missing';
      case ValidationIssue.unrealisticCalories:
        return 'Calorie values are outside realistic range';
      case ValidationIssue.incompleteResponse:
        return 'Response appears to be incomplete';
      case ValidationIssue.formatError:
        return 'Response format is invalid';
      case ValidationIssue.invalidWeight:
        return 'Weight value is invalid';
      case ValidationIssue.invalidBMI:
        return 'BMI calculation resulted in invalid value';
      case ValidationIssue.unrealisticExerciseCalories:
        return 'Exercise calories are unrealistically high';
      case ValidationIssue.missingRequiredData:
        return 'Required data is missing';
      case ValidationIssue.dataCorruption:
        return 'Data appears to be corrupted';
    }
  }
}