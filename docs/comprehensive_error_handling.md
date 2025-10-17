# Comprehensive Error Handling System

This document describes the comprehensive error handling system implemented for the OpenNutriTracker app. The system provides graceful degradation, user-friendly error messages, recovery options, and comprehensive logging for debugging and analytics.

## Overview

The error handling system consists of several key components:

1. **Exception Hierarchy**: Structured exception classes for different types of errors
2. **Error Handling Service**: Central service for handling errors with appropriate UI feedback
3. **Graceful Degradation Service**: Ensures features fail gracefully without breaking the app
4. **Error Logging Service**: Comprehensive logging for debugging and analytics
5. **Recovery Options Service**: Provides user-friendly recovery mechanisms
6. **Error Display Widgets**: UI components for displaying errors to users
7. **Error Handling Mixin**: Convenient mixin for consistent error handling across screens

## Exception Hierarchy

### Base Exception: AppException

All application-specific exceptions extend from `AppException`:

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
}
```

### Specific Exception Types

- **ValidationException**: For validation-related errors (LLM responses, user input)
- **LogisticsException**: For logistics tracking failures
- **WeightCheckinException**: For weight check-in related errors
- **CalorieCalculationException**: For calorie calculation errors
- **NotificationException**: For notification system errors

## Error Handling Service

The `ErrorHandlingService` provides centralized error handling with appropriate UI feedback:

```dart
// Handle validation errors with recovery options
ErrorHandlingService.handleValidationError(
  context,
  validationError,
  onRetry: () => retryOperation(),
  onDismiss: () => dismissError(),
);

// Handle general app errors
ErrorHandlingService.handleAppError(
  context,
  appError,
  onRetry: () => retryOperation(),
);

// Graceful degradation for operations
final result = ErrorHandlingService.handleWithGracefulDegradation<String>(
  () => riskyOperation(),
  'fallback_value',
  operationName: 'Fetch user data',
);
```

## Graceful Degradation Service

The `GracefulDegradationService` ensures features fail gracefully:

```dart
final service = GracefulDegradationService();

// Execute with fallback
final result = await service.executeWithFallback<String>(
  featureName: 'logistics_tracking',
  primaryOperation: () async => trackUserAction(),
  fallbackOperation: () => 'tracking_disabled',
);

// Specific error handlers
service.handleLogisticsFailure('meal_logging', error);
final response = service.handleLLMValidationFailure(originalResponse, error);
final bmi = service.handleBMICalculationFailure(height, weight, error);
```

## Error Logging Service

The `ErrorLoggingService` provides comprehensive logging:

```dart
final loggingService = ErrorLoggingService();

// Log application errors
await loggingService.logError(
  appException,
  context: {'userId': 'user123', 'action': 'meal_logging'},
  userId: 'user123',
);

// Log custom errors
await loggingService.logCustomError(
  'Custom operation failed',
  errorType: 'CustomError',
  severity: ErrorSeverity.warning,
  context: {'operation': 'data_sync'},
);

// Get error statistics
final stats = await loggingService.getErrorStatistics(
  period: Duration(days: 7),
);
```

## Error Handling Mixin

Use the `ErrorHandlingMixin` for consistent error handling across screens:

```dart
class MyScreen extends StatefulWidget {
  // ...
}

class _MyScreenState extends State<MyScreen> with ErrorHandlingMixin {
  
  void _performOperation() async {
    final result = await executeWithErrorHandling<String>(
      operationName: 'Load user data',
      operation: () async => loadUserData(),
      fallbackValue: 'default_data',
      showUserError: true,
    );
    
    if (result != null) {
      // Handle success
    }
  }
  
  void _performWithGracefulDegradation() async {
    final result = await executeWithGracefulDegradation<String>(
      featureName: 'advanced_analytics',
      primaryOperation: () async => calculateAdvancedMetrics(),
      fallbackOperation: () => calculateBasicMetrics(),
    );
    
    // Use result (either advanced or basic metrics)
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your UI components
          if (isFeatureDisabled('advanced_analytics'))
            Text('Advanced analytics unavailable, using basic metrics'),
        ],
      ),
    );
  }
}
```

## Error Display Widgets

### ErrorDisplayWidget

Full-featured error display with recovery options:

```dart
ErrorDisplayWidget(
  error: validationException,
  onRetry: () => retryOperation(),
  onDismiss: () => dismissError(),
  showRecoveryOptions: true,
  showDetails: true,
)
```

### CompactErrorWidget

Compact error display for inline use:

```dart
CompactErrorWidget(
  error: appException,
  onRetry: () => retryOperation(),
  onDismiss: () => dismissError(),
)
```

### ErrorBannerWidget

Top-level error banner:

```dart
ErrorBannerWidget(
  error: appException,
  isVisible: showError,
  onRetry: () => retryOperation(),
  onDismiss: () => hideError(),
)
```

## Recovery Options Service

The `RecoveryOptionsService` provides user-friendly recovery mechanisms:

```dart
final recoveryService = RecoveryOptionsService();

// Show recovery dialog
recoveryService.showRecoveryDialog(
  context,
  appException,
  onDismiss: () => handleDismiss(),
);

// Get recovery options programmatically
final options = recoveryService.getRecoveryOptions(appException);
```

## Integration Examples

### BLoC Integration

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final ErrorLoggingService _loggingService = ErrorLoggingService();
  
  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    try {
      // Process event
      yield SuccessState(result);
    } catch (error, stackTrace) {
      final appError = error is AppException
          ? error
          : AppException(
              'Operation failed',
              originalError: error,
              stackTrace: stackTrace,
            );
      
      await _loggingService.logError(appError);
      yield ErrorState(appError);
    }
  }
}
```

### Repository Integration

```dart
class MyRepository {
  Future<String> fetchData() async {
    return ErrorHandlingService.handleAsyncWithGracefulDegradation<String>(
      () async {
        // API call that might fail
        return await apiCall();
      },
      'cached_data', // Fallback value
      operationName: 'Fetch remote data',
    );
  }
}
```

### UseCase Integration

```dart
class MyUseCase {
  final GracefulDegradationService _degradationService = GracefulDegradationService();
  
  Future<Result> execute(Input input) async {
    return await _degradationService.executeWithFallback<Result>(
      featureName: 'advanced_processing',
      primaryOperation: () async => advancedProcessing(input),
      fallbackOperation: () => basicProcessing(input),
    );
  }
}
```

## Feature-Specific Error Handling

### Logistics Tracking Errors

```dart
// Graceful degradation - app continues normally
handleLogisticsError(error, 'meal_logging');
```

### LLM Validation Errors

```dart
// Return original response with warning
final response = handleLLMValidationError(originalResponse, validationError);
```

### BMI Calculation Errors

```dart
// Use fallback calculation or default value
final bmi = handleBMICalculationError(height, weight, error);
```

### Weight Check-in Errors

```dart
// Allow manual entry without automated features
final success = await handleWeightCheckinError(error);
```

### Notification Errors

```dart
// Continue without notifications
final enabled = await handleNotificationError(error);
```

## Best Practices

### 1. Use Appropriate Exception Types

```dart
// Good: Specific exception type
throw ValidationException(
  'Calorie value is unrealistic',
  ValidationSeverity.warning,
  [ValidationIssue.unrealisticCalories],
  correctedValue: '500',
);

// Avoid: Generic exception
throw Exception('Something went wrong');
```

### 2. Provide Context in Error Logging

```dart
// Good: Rich context
await loggingService.logError(
  error,
  context: {
    'userId': user.id,
    'action': 'meal_logging',
    'mealType': 'breakfast',
    'timestamp': DateTime.now().toIso8601String(),
  },
  userId: user.id,
);
```

### 3. Use Graceful Degradation for Non-Critical Features

```dart
// Good: Non-critical feature with fallback
final analytics = executeWithGracefulDegradation(
  featureName: 'advanced_analytics',
  primaryOperation: () => calculateAdvancedMetrics(),
  fallbackOperation: () => calculateBasicMetrics(),
);

// Avoid: Letting non-critical features break the app
final analytics = calculateAdvancedMetrics(); // Might crash the app
```

### 4. Provide User-Friendly Error Messages

```dart
// Good: User-friendly message
const ValidationException(
  'Please enter a weight between 30-300 kg (66-660 lbs)',
  ValidationSeverity.error,
  [ValidationIssue.invalidWeight],
);

// Avoid: Technical error message
const ValidationException(
  'Weight validation failed: value out of bounds',
  ValidationSeverity.error,
  [ValidationIssue.invalidWeight],
);
```

### 5. Implement Recovery Options

```dart
// Good: Provide recovery options
showRecoveryDialog(context, error);

// Better: Handle recovery automatically when possible
if (error.correctedValue != null) {
  useCorrectValue(error.correctedValue);
} else {
  showRecoveryDialog(context, error);
}
```

## Testing

The error handling system includes comprehensive tests:

- Unit tests for all services and exception classes
- Widget tests for error display components
- Integration tests for error handling flows

Run tests with:

```bash
flutter test test/unit_test/core/domain/service/
flutter test test/widget_test/core/presentation/widgets/
```

## Configuration

Register error handling services in your dependency injection:

```dart
// In locator.dart
locator.registerLazySingleton<ErrorHandlingService>(() => ErrorHandlingService());
locator.registerLazySingleton<ErrorLoggingService>(() => ErrorLoggingService());
locator.registerLazySingleton<GracefulDegradationService>(() => GracefulDegradationService());
locator.registerLazySingleton<RecoveryOptionsService>(() => RecoveryOptionsService());
```

## Monitoring and Analytics

The error logging service provides comprehensive error statistics:

- Total error counts by severity
- Error rates and trends
- Error distribution by type
- User-specific error patterns

Use these metrics to:
- Identify problematic features
- Monitor app stability
- Prioritize bug fixes
- Improve user experience

## Conclusion

This comprehensive error handling system ensures that the OpenNutriTracker app provides a robust, user-friendly experience even when things go wrong. By implementing graceful degradation, comprehensive logging, and user-friendly recovery options, the app maintains functionality and provides valuable insights for continuous improvement.