# OpenNutriTracker API Documentation

This document provides comprehensive API documentation for the enhanced features in OpenNutriTracker, including use cases, entities, and service interfaces.

## Table of Contents
- [Logistics Tracking API](#logistics-tracking-api)
- [LLM Response Validation API](#llm-response-validation-api)
- [Enhanced Calorie Calculation API](#enhanced-calorie-calculation-api)
- [Exercise Calorie Tracking API](#exercise-calorie-tracking-api)
- [Weight Check-in API](#weight-check-in-api)
- [Error Handling API](#error-handling-api)

## Logistics Tracking API

### LogisticsTrackingUsecase

Handles tracking of user interactions and app usage patterns.

#### Methods

##### `trackUserAction(LogisticsEventType type, Map<String, dynamic> data)`
Records a user action event.

**Parameters:**
- `type`: The type of event being tracked
- `data`: Additional event data

**Example:**
```dart
await logisticsTrackingUsecase.trackUserAction(
  LogisticsEventType.mealLogged,
  {
    'mealType': 'breakfast',
    'itemCount': 3,
    'totalCalories': 450
  }
);
```

##### `trackChatInteraction(String message, String response, Duration responseTime)`
Records AI chat interactions.

**Parameters:**
- `message`: User's input message
- `response`: AI's response
- `responseTime`: Time taken to generate response

##### `trackNavigation(String fromScreen, String toScreen)`
Records screen navigation events.

**Parameters:**
- `fromScreen`: Source screen name
- `toScreen`: Destination screen name

### LogisticsDataSource

Handles local storage of logistics data.

#### Methods

##### `logUserAction(LogisticsEventEntity event)`
Stores a logistics event locally.

##### `rotateLogsIfNeeded()`
Manages log file rotation when size limits are exceeded.

##### `getLogsByDateRange(DateTime start, DateTime end)`
Retrieves logs within a specified date range.

### Entities

#### LogisticsEventEntity
```dart
class LogisticsEventEntity {
  final String id;
  final LogisticsEventType eventType;
  final Map<String, dynamic> eventData;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;
}
```

#### LogisticsEventType Enum
```dart
enum LogisticsEventType {
  mealLogged,
  exerciseLogged,
  weightCheckin,
  chatInteraction,
  screenNavigation,
  settingsChanged,
  goalUpdated
}
```

## LLM Response Validation API

### LLMResponseValidator

Service for validating AI chat responses.

#### Methods

##### `validateResponse(String response)`
Validates an AI response for quality and accuracy.

**Returns:** `ValidationResult`

**Example:**
```dart
final validator = LLMResponseValidator();
final result = validator.validateResponse(aiResponse);

if (!result.isValid) {
  // Handle validation failure
  handleValidationError(result);
}
```

##### `isResponseSizeReasonable(String response)`
Checks if response length is within acceptable limits.

**Returns:** `bool`

##### `containsRequiredNutritionInfo(String response)`
Validates that nutrition responses contain required information.

**Returns:** `bool`

##### `areCalorieValuesRealistic(Map<String, dynamic> nutritionData)`
Validates calorie values for believability.

**Returns:** `bool`

### Entities

#### ValidationResult
```dart
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final String? correctedResponse;
  final ValidationSeverity severity;
}
```

#### ValidationSeverity Enum
```dart
enum ValidationSeverity { info, warning, error, critical }
```

#### ValidationIssue Enum
```dart
enum ValidationIssue {
  responseTooLarge,
  missingNutritionInfo,
  unrealisticCalories,
  incompleteResponse,
  formatError
}
```

## Enhanced Calorie Calculation API

### EnhancedCalorieGoalCalc

Utility class for BMI-adjusted calorie calculations.

#### Static Methods

##### `calculateBMIAdjustedTDEE(UserEntity user, double exerciseCalories)`
Calculates TDEE with BMI and exercise adjustments.

**Parameters:**
- `user`: User entity with profile information
- `exerciseCalories`: Total exercise calories for the day

**Returns:** `double` - Adjusted TDEE

**Example:**
```dart
final adjustedTDEE = EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(
  user,
  totalExerciseCalories
);
```

##### `getPersonalizedRecommendation(UserEntity user, double exerciseCalories)`
Generates personalized calorie recommendations.

**Returns:** `CalorieRecommendation`

##### `getBMIAdjustmentFactor(double bmi, UserWeightGoalEntity goal)`
Calculates BMI-based adjustment factor.

**Returns:** `double` - Adjustment multiplier

### Entities

#### CalorieRecommendation
```dart
class CalorieRecommendation {
  final double baseTDEE;
  final double exerciseCalories;
  final double bmiAdjustment;
  final double netCalories;
  final List<String> recommendations;
  final BMICategory bmiCategory;
}
```

#### BMICategory Enum
```dart
enum BMICategory { underweight, normal, overweight, obese }
```

## Exercise Calorie Tracking API

### Enhanced User Activity System

#### EnhancedUserActivityEntity
```dart
class EnhancedUserActivityEntity extends UserActivityEntity {
  final double caloriesBurned;
  final bool isManualCalorieEntry;
  final ActivityIntensity intensity;
  final Map<String, dynamic>? additionalMetrics;
  
  double get netCalorieImpact => caloriesBurned * -1;
}
```

#### ActivityIntensity Enum
```dart
enum ActivityIntensity { light, moderate, vigorous, extreme }
```

### CalorieValidationService

Validates exercise calorie entries.

#### Methods

##### `validateCalorieBurn(double calories, String activityType, int durationMinutes)`
Validates if calorie burn is realistic for the activity.

**Returns:** `ValidationResult`

##### `getRecommendedCalorieBurn(String activityType, int durationMinutes, double weightKg)`
Calculates recommended calorie burn based on MET values.

**Returns:** `double`

## Weight Check-in API

### WeightCheckinUsecase

Manages weight tracking functionality.

#### Methods

##### `recordWeightEntry(double weight, String? notes)`
Records a new weight entry.

**Parameters:**
- `weight`: Weight in kilograms
- `notes`: Optional notes about the entry

**Example:**
```dart
await weightCheckinUsecase.recordWeightEntry(70.5, "Morning weight after workout");
```

##### `getWeightHistory(int days)`
Retrieves weight history for specified number of days.

**Returns:** `List<WeightEntryEntity>`

##### `calculateWeightTrend(int days)`
Calculates weight trend over specified period.

**Returns:** `WeightTrend`

##### `shouldShowCheckinReminder()`
Determines if check-in reminder should be displayed.

**Returns:** `bool`

##### `scheduleNextCheckin()`
Schedules the next weight check-in reminder.

### WeightCheckinDataSource

Handles local storage of weight data.

#### Methods

##### `saveWeightEntry(WeightEntryDBO weightEntry)`
Stores weight entry locally.

##### `getWeightHistory(DateTime? startDate, DateTime? endDate)`
Retrieves weight entries within date range.

##### `setCheckinFrequency(CheckinFrequency frequency)`
Sets user's preferred check-in frequency.

### Entities

#### WeightEntryEntity
```dart
class WeightEntryEntity {
  final String id;
  final double weightKG;
  final DateTime timestamp;
  final String? notes;
  final double? bodyFatPercentage;
  final double? muscleMass;
  
  double get weightLbs => weightKG * 2.20462;
  BMICategory get bmiCategory => BMICalc.getBMICategory(bmi);
}
```

#### CheckinFrequency Enum
```dart
enum CheckinFrequency { daily, weekly, biweekly, monthly }
```

#### WeightTrend
```dart
class WeightTrend {
  final double averageWeeklyChange;
  final TrendDirection direction;
  final double totalChange;
  final int daysTracked;
  final double confidence;
}
```

## Error Handling API

### ErrorHandlingService

Centralized error handling for enhanced features.

#### Methods

##### `handleValidationError(ValidationException error)`
Handles validation-related errors.

##### `handleLogisticsError(Exception error)`
Handles logistics tracking errors.

##### `handleWeightTrackingError(Exception error)`
Handles weight tracking errors.

### GracefulDegradationService

Provides fallback functionality when features fail.

#### Methods

##### `handleFeatureFailure(String featureName, Exception error)`
Provides graceful degradation for failed features.

##### `getFallbackCalorieGoal(UserEntity user)`
Provides fallback calorie calculation when enhanced calculation fails.

### Exceptions

#### ValidationException
```dart
class ValidationException implements Exception {
  final String message;
  final ValidationSeverity severity;
  final List<ValidationIssue> issues;
}
```

#### LogisticsException
```dart
class LogisticsException implements Exception {
  final String message;
  final LogisticsEventType? eventType;
  final Map<String, dynamic>? context;
}
```

## Usage Examples

### Complete Exercise Logging Flow
```dart
// 1. Log exercise activity
final activity = EnhancedUserActivityEntity(
  name: "Running",
  caloriesBurned: 300,
  intensity: ActivityIntensity.vigorous,
  duration: Duration(minutes: 30),
);

// 2. Validate calorie burn
final validation = await calorieValidationService.validateCalorieBurn(
  300, "running", 30
);

if (validation.isValid) {
  // 3. Save activity
  await activityUsecase.saveActivity(activity);
  
  // 4. Track the action
  await logisticsTrackingUsecase.trackUserAction(
    LogisticsEventType.exerciseLogged,
    activity.toMap()
  );
  
  // 5. Update calorie goals
  final updatedTDEE = EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(
    user, getTotalExerciseCalories()
  );
}
```

### Weight Check-in Flow
```dart
// 1. Check if reminder should be shown
if (await weightCheckinUsecase.shouldShowCheckinReminder()) {
  // 2. Show weight input UI
  final weight = await showWeightInputDialog();
  
  // 3. Record weight entry
  await weightCheckinUsecase.recordWeightEntry(weight, notes);
  
  // 4. Update BMI and calorie goals
  final updatedUser = await userUsecase.updateUserWeight(weight);
  final newCalorieGoal = EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
    updatedUser, 0
  );
  
  // 5. Track the check-in
  await logisticsTrackingUsecase.trackUserAction(
    LogisticsEventType.weightCheckin,
    {'weight': weight, 'bmi': updatedUser.bmi}
  );
}
```

## Integration Notes

### BLoC Integration
All new use cases integrate with existing BLoC pattern:
- Use cases are injected into BLoCs via dependency injection
- State updates trigger UI rebuilds
- Events are processed asynchronously

### Data Persistence
- Hive database for local storage
- Encrypted storage for sensitive data
- Automatic data migration for schema updates

### Cross-Platform Considerations
- Platform-specific implementations for notifications
- Native scrolling behaviors for table rendering
- Responsive design for different screen sizes

## Testing

### Unit Tests
Each use case and service includes comprehensive unit tests:
- Input validation testing
- Error handling verification
- Edge case coverage
- Mock dependencies

### Integration Tests
End-to-end testing for complete workflows:
- Exercise logging with calorie calculation
- Weight check-in with BMI updates
- AI validation with error handling

### Widget Tests
UI component testing:
- Input validation widgets
- Chart rendering components
- Error display widgets

---

For implementation details and code examples, refer to the source code in the respective feature directories.