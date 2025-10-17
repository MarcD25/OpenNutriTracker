import 'package:flutter/material.dart';
import '../../domain/exception/app_exception.dart';
import '../../domain/service/error_handling_service.dart';
import '../../domain/service/recovery_options_service.dart';
import '../../domain/service/graceful_degradation_service.dart';

/// Mixin for handling errors consistently across the app
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  final ErrorHandlingService _errorHandlingService = ErrorHandlingService();
  final RecoveryOptionsService _recoveryService = RecoveryOptionsService();
  final GracefulDegradationService _degradationService = GracefulDegradationService();

  /// Handle any app exception with appropriate UI feedback
  void handleError(
    AppException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRecoveryOptions = false,
  }) {
    if (!mounted) return;

    if (showRecoveryOptions) {
      _recoveryService.showRecoveryDialog(
        context,
        error,
        onDismiss: onDismiss,
      );
    } else {
      ErrorHandlingService.handleAppError(
        context,
        error,
        onRetry: onRetry,
        onDismiss: onDismiss,
      );
    }
  }

  /// Handle validation errors specifically
  void handleValidationError(
    ValidationException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRecoveryOptions = true,
  }) {
    if (!mounted) return;

    if (showRecoveryOptions) {
      _recoveryService.showRecoveryDialog(
        context,
        error,
        onDismiss: onDismiss,
      );
    } else {
      ErrorHandlingService.handleValidationError(
        context,
        error,
        onRetry: onRetry,
        onDismiss: onDismiss,
      );
    }
  }

  /// Execute operation with error handling and graceful degradation
  Future<T?> executeWithErrorHandling<T>({
    required String operationName,
    required Future<T> Function() operation,
    T? fallbackValue,
    bool showUserError = true,
    bool logError = true,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final appError = error is AppException
          ? error
          : AppException(
              'Operation failed: $operationName',
              originalError: error,
              stackTrace: stackTrace,
            );

      if (logError) {
        // Error will be logged by the error handling service
      }

      if (showUserError && mounted) {
        handleError(appError);
      }

      onError?.call();
      return fallbackValue;
    }
  }

  /// Execute operation with graceful degradation
  Future<T> executeWithGracefulDegradation<T>({
    required String featureName,
    required Future<T> Function() primaryOperation,
    required T Function() fallbackOperation,
    bool showUserError = false,
    Duration? timeout,
  }) async {
    return await _degradationService.executeWithFallback<T>(
      featureName: featureName,
      primaryOperation: primaryOperation,
      fallbackOperation: fallbackOperation,
      timeout: timeout,
      logFailure: true,
    );
  }

  /// Execute synchronous operation with graceful degradation
  T executeWithGracefulDegradationSync<T>({
    required String featureName,
    required T Function() primaryOperation,
    required T Function() fallbackOperation,
    bool showUserError = false,
  }) {
    return _degradationService.executeWithFallbackSync<T>(
      featureName: featureName,
      primaryOperation: primaryOperation,
      fallbackOperation: fallbackOperation,
      logFailure: true,
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show warning snackbar
  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show info snackbar
  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }

  /// Create retry button for error states
  Widget createRetryButton({
    required VoidCallback onRetry,
    String text = 'Retry',
  }) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(text),
    );
  }

  /// Create error state widget
  Widget createErrorStateWidget({
    required String message,
    VoidCallback? onRetry,
    String? retryText,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              createRetryButton(
                onRetry: onRetry,
                text: retryText ?? 'Retry',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Create loading state widget with error handling
  Widget createLoadingStateWidget({
    String? message,
    VoidCallback? onCancel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle logistics tracking errors gracefully
  void handleLogisticsError(dynamic error, String operation) {
    _degradationService.handleLogisticsFailure(operation, error);
  }

  /// Handle LLM validation errors gracefully
  String handleLLMValidationError(String originalResponse, ValidationException error) {
    return _degradationService.handleLLMValidationFailure(originalResponse, error);
  }

  /// Handle BMI calculation errors gracefully
  double handleBMICalculationError(double height, double weight, dynamic error) {
    return _degradationService.handleBMICalculationFailure(height, weight, error);
  }

  /// Handle calorie calculation errors gracefully
  double handleCalorieCalculationError(dynamic error, {double? fallbackValue}) {
    return _degradationService.handleCalorieCalculationFailure(error, fallbackValue: fallbackValue);
  }

  /// Handle weight check-in errors gracefully
  Future<bool> handleWeightCheckinError(dynamic error) async {
    return await _degradationService.handleWeightCheckinFailure(error);
  }

  /// Handle notification errors gracefully
  Future<bool> handleNotificationError(dynamic error) async {
    return await _degradationService.handleNotificationFailure(error);
  }

  /// Check if a feature is currently disabled
  bool isFeatureDisabled(String featureName) {
    return _degradationService.isFeatureDisabled(featureName);
  }

  /// Reset feature status
  void resetFeatureStatus(String featureName) {
    _degradationService.resetFeatureStatus(featureName);
  }
}