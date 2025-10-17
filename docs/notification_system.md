# Cross-Platform Notification System

This document describes the implementation of the cross-platform notification system for weight check-in reminders in OpenNutriTracker.

## Overview

The notification system provides gentle reminders for users to check in with their weight based on their preferred frequency. It's designed to be non-intrusive and respects user privacy and platform-specific guidelines.

## Architecture

### Core Components

1. **WeightCheckinNotificationService** - Main service handling notification scheduling and management
2. **NotificationManager** - Central manager for all notification services in the app
3. **NotificationSettingsWidget** - UI component for managing notification preferences

### Platform Support

- **Android**: Uses notification channels with proper permissions (API 33+)
- **iOS**: Implements iOS notification permissions and guidelines
- **Web**: Gracefully degrades (notifications not supported)

## Features

### Notification Scheduling
- Daily, weekly, bi-weekly, and monthly reminder frequencies
- Customizable reminder times (default: 9:00 AM)
- Automatic rescheduling after weight entries

### Permission Management
- Cross-platform permission requests
- Graceful handling of denied permissions
- Settings integration for easy permission management

### Gentle Reminders
- Non-intrusive notification style
- No vibration by default
- Passive interruption level on iOS
- Fallback to in-app reminders when notifications are unavailable

## Implementation Details

### Android Configuration

**Permissions** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

**Notification Channel**:
- Channel ID: `weight_checkin_reminders`
- Importance: Default (no heads-up notifications)
- No vibration for gentle reminders

### iOS Configuration

**Info.plist**:
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>This app uses notifications to remind you about weight check-ins to help track your health progress.</string>
```

**Features**:
- Passive interruption level for gentle reminders
- Proper permission request flow
- Background processing capability

### Usage

#### Initialization
```dart
// Initialize in main.dart
await NotificationManager().initialize();
```

#### Scheduling Reminders
```dart
final notificationService = locator<WeightCheckinNotificationService>();
await notificationService.scheduleReminder(
  scheduledDate: DateTime.now().add(Duration(days: 1)),
  frequency: CheckinFrequency.daily,
);
```

#### Permission Management
```dart
final hasPermission = await NotificationManager().requestAllPermissions();
if (!hasPermission) {
  // Show settings dialog or use in-app reminders
}
```

## User Experience

### Settings Integration
- Toggle notifications on/off in Settings screen
- Automatic permission request when enabling
- Clear feedback about permission status

### Fallback Mechanisms
- In-app reminder banners when notifications are disabled
- Graceful degradation on unsupported platforms
- No app crashes if notification services fail

### Privacy Considerations
- No personal data in notification content
- Local-only notification scheduling
- User control over all notification preferences

## Testing

### Unit Tests
- Service initialization and configuration
- Permission request handling
- Notification scheduling and cancellation
- Cross-platform compatibility

### Integration Tests
- End-to-end notification flow
- Settings integration
- Permission management
- Fallback mechanisms

## Troubleshooting

### Common Issues

1. **Notifications not appearing**
   - Check device notification settings
   - Verify app has notification permissions
   - Ensure Do Not Disturb is not blocking notifications

2. **Permission requests failing**
   - Check platform-specific permission requirements
   - Verify manifest/Info.plist configuration
   - Test on different OS versions

3. **Scheduling failures**
   - Check for exact alarm permissions on Android 12+
   - Verify timezone configuration
   - Test with different scheduling intervals

### Debug Information
- Use `getPendingNotifications()` to check scheduled notifications
- Monitor logs for initialization and scheduling errors
- Test in-app fallback reminders

## Future Enhancements

- Custom notification sounds
- Rich notification content with progress charts
- Smart scheduling based on user patterns
- Integration with health platforms
- Notification analytics and optimization