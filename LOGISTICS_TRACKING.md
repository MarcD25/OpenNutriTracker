# Logistics Tracking System

The logistics tracking system provides comprehensive user interaction and performance monitoring for the OpenNutriTracker app. It's designed to be privacy-focused, efficient, and easy to integrate across all screens.

## Overview

The system consists of three main components:

1. **LogisticsDataSource** - Handles data storage and retrieval with Hive
2. **LogisticsTrackingUsecase** - Business logic for tracking various events
3. **LogisticsTrackingMixin** - Easy-to-use mixin for UI integration

## Features

### Privacy & Security
- Sensitive data is automatically hashed using SHA-256
- User messages and responses are never stored in plain text
- Configurable data encryption for all logistics data
- Automatic log rotation to prevent storage bloat

### Event Types Supported
- User actions (button presses, form submissions)
- Navigation between screens
- Meal logging activities
- Exercise logging activities
- Weight check-ins
- Settings changes
- Goal updates
- Chat interactions (with privacy protection)
- App lifecycle events
- Performance metrics
- Error tracking

### Automatic Features
- Log rotation when storage exceeds limits (10,000 entries by default)
- Graceful error handling (never disrupts user experience)
- Background processing for heavy operations
- Efficient batching for multiple events

## Quick Start

### 1. Add the Mixin to Your Screen

```dart
import 'package:opennutritracker/core/presentation/mixins/logistics_tracking_mixin.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with LogisticsTrackingMixin {
  @override
  void initState() {
    super.initState();
    // Track when screen is viewed
    trackScreenView('MyScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          // Track button press
          trackButtonPress('save_button', 'MyScreen');
          // Your button logic here
        },
        child: Text('Save'),
      ),
    );
  }
}
```

### 2. Track Common Actions

```dart
// Track meal logging
trackMealLogged('breakfast', 3, 450.0);

// Track exercise logging
trackExerciseLogged('running', Duration(minutes: 30), 250.0);

// Track weight check-in
trackWeightCheckin(70.5, 'kg');

// Track navigation
trackNavigation('HomePage', 'SettingsPage');

// Track settings changes
trackSettingsChanged('theme', 'light', 'dark');

// Track goal updates
trackGoalUpdated('calorie_goal', 2000, 2200);
```

### 3. Track Chat Interactions

```dart
// Chat interactions are automatically privacy-protected
trackChatInteraction(
  'What should I eat for breakfast?',
  'I recommend oatmeal with fruits.',
  Duration(milliseconds: 1500),
);
```

### 4. Track Performance

```dart
final stopwatch = Stopwatch()..start();
// Your operation here
stopwatch.stop();

trackPerformance(
  'data_processing',
  stopwatch.elapsed,
  'MyScreen',
  isSuccessful: true,
);
```

### 5. Track Errors

```dart
try {
  // Your code here
} catch (e, stackTrace) {
  trackError(
    'network_error',
    e.toString(),
    'MyScreen',
    stackTrace: stackTrace.toString(),
  );
}
```

## Advanced Usage

### Custom Event Tracking

```dart
trackAction(
  LogisticsEventType.userAction,
  {
    'custom_feature': 'advanced_calculator',
    'calculation_type': 'macro_distribution',
    'result_accuracy': 0.95,
  },
  metadata: {
    'feature_category': 'advanced_tools',
    'user_level': 'expert',
  },
);
```

### Direct Usecase Usage

```dart
final logisticsUsecase = locator<LogisticsTrackingUsecase>();

await logisticsUsecase.trackUserAction(
  LogisticsEventType.mealLogged,
  {'meal_type': 'breakfast', 'calories': 300},
  userId: 'user123',
  metadata: {'source': 'manual_entry'},
);
```

## Data Structure

### Event Data
Each logged event contains:
- **id**: Unique identifier
- **eventType**: Type of event (enum)
- **eventData**: Event-specific data (Map)
- **timestamp**: When the event occurred
- **userId**: Optional user identifier
- **metadata**: Additional context information

### Privacy Protection
- Sensitive fields are automatically detected and hashed
- Original content is never stored for sensitive data
- Only metadata like length, response time, etc. are stored
- All data is encrypted at rest using Hive encryption

## Configuration

### Log Rotation
The system automatically rotates logs when they exceed 10,000 entries, keeping the most recent 70% of entries.

### Storage Location
All logistics data is stored in the encrypted Hive database alongside other app data.

### Performance Impact
- Minimal performance impact on UI thread
- Background processing for heavy operations
- Efficient storage with automatic cleanup
- Graceful degradation if tracking fails

## Analytics & Insights

### Getting Analytics Data

```dart
final logisticsUsecase = locator<LogisticsTrackingUsecase>();
final analytics = await logisticsUsecase.getAnalyticsData(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);

print('Total events: ${analytics['total_events']}');
print('Event types: ${analytics['event_types']}');
print('Daily activity: ${analytics['daily_activity']}');
```

### Available Metrics
- Total events by type
- Daily activity patterns
- User engagement metrics
- Performance statistics
- Error frequency and types

## Best Practices

### 1. Track User Intent, Not Just Actions
```dart
// Good: Track the intent behind the action
trackButtonPress('save_meal', 'AddMealScreen', additionalData: {
  'meal_type': 'breakfast',
  'item_count': 3,
  'user_confidence': 'high',
});

// Avoid: Just tracking the button press
trackButtonPress('button_1', 'Screen_A');
```

### 2. Use Meaningful Event Names
```dart
// Good: Descriptive and consistent
trackMealLogged('breakfast', itemCount, totalCalories);

// Avoid: Generic or unclear names
trackAction(LogisticsEventType.userAction, {'type': 'food'});
```

### 3. Include Context in Metadata
```dart
trackNavigation('HomePage', 'DiaryPage', additionalData: {
  'navigation_trigger': 'bottom_tab',
  'user_session_duration': sessionDuration.inMinutes,
  'previous_actions_count': actionCount,
});
```

### 4. Handle Errors Gracefully
The system is designed to never disrupt the user experience. All tracking methods handle errors internally and log warnings instead of throwing exceptions.

### 5. Respect User Privacy
- Never log personally identifiable information in plain text
- Use the built-in hashing for sensitive data
- Consider user consent for detailed tracking
- Regularly review what data is being collected

## Troubleshooting

### Common Issues

1. **Events not being logged**
   - Check if LogisticsTrackingUsecase is registered in locator
   - Verify Hive database is properly initialized
   - Check logs for any error messages

2. **Performance issues**
   - Ensure you're not tracking too frequently (e.g., on every scroll)
   - Use background processing for heavy analytics
   - Consider reducing metadata size for high-frequency events

3. **Storage growing too large**
   - Log rotation should handle this automatically
   - Check if rotation is working properly
   - Consider reducing the maximum log entries limit

### Debug Mode
Enable debug logging to see tracking activity:

```dart
import 'package:logging/logging.dart';

Logger.root.level = Level.FINE;
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});
```

## Integration Examples

See `lib/core/presentation/mixins/logistics_tracking_example.dart` for comprehensive examples of how to integrate the logistics tracking system into your screens.

## Requirements Satisfied

This implementation satisfies the following requirements:

- **1.1**: Logs user actions to local logistics file
- **1.2**: Records chat outputs with timestamps (privacy-protected)
- **1.3**: Tracks navigation patterns between screens
- **1.4**: Records key actions (meal logging, exercise entry, weight updates)
- **1.5**: Implements log rotation to prevent storage issues
- **1.6**: Ensures user privacy and data encryption
- **1.7**: Complies with iOS file system restrictions and privacy guidelines