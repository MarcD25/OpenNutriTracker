/// Base exception class for all application-specific exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Exception for validation-related errors
class ValidationException extends AppException {
  final ValidationSeverity severity;
  final List<ValidationIssue> issues;
  final String? correctedValue;

  const ValidationException(
    String message,
    this.severity,
    this.issues, {
    this.correctedValue,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'ValidationException: $message (Severity: $severity)';
}

/// Exception for logistics tracking failures
class LogisticsException extends AppException {
  const LogisticsException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for weight check-in related errors
class WeightCheckinException extends AppException {
  const WeightCheckinException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for calorie calculation errors
class CalorieCalculationException extends AppException {
  const CalorieCalculationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for notification system errors
class NotificationException extends AppException {
  const NotificationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Validation severity levels
enum ValidationSeverity { info, warning, error, critical }

/// Types of validation issues
enum ValidationIssue {
  responseTooLarge,
  missingNutritionInfo,
  unrealisticCalories,
  incompleteResponse,
  formatError,
  invalidWeight,
  invalidBMI,
  unrealisticExerciseCalories,
  missingRequiredData,
  dataCorruption,
}