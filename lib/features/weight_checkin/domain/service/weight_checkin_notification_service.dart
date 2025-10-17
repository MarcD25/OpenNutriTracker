import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

/// Service for handling weight check-in notifications across platforms
class WeightCheckinNotificationService {
  static const String _channelId = 'weight_checkin_reminders';
  static const String _channelName = 'Weight Check-in Reminders';
  static const String _channelDescription = 'Gentle reminders to check in with your weight';
  static const int _notificationId = 1001;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (kIsWeb) {
      // Web doesn't support local notifications
      return;
    }

    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Initialize timezone data
    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      await _initializeAndroid();
    } else if (Platform.isIOS) {
      await _initializeIOS();
    }

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return false;
    }

    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSPermissions();
    }

    return false;
  }

  /// Schedule a weight check-in reminder
  Future<void> scheduleReminder({
    required DateTime scheduledDate,
    required CheckinFrequency frequency,
  }) async {
    if (kIsWeb || !_isInitialized) {
      return;
    }

    // Cancel any existing reminders first
    await cancelAllReminders();

    final title = 'Weight Check-in Reminder';
    final body = _getReminderMessage(frequency);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to showing in-app reminder
      rethrow;
    }
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    if (kIsWeb || !_isInitialized) {
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.cancel(_notificationId);
    } catch (e) {
      print('Error cancelling notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb || !_isInitialized) {
      return false;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    return false;
  }

  Future<void> _initializeAndroid() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
      enableVibration: false, // Gentle reminder - no vibration
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_gentle'),
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> _initializeIOS() async {
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request this explicitly
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<bool> _requestAndroidPermissions() async {
    // For Android 13+ (API level 33), we need to request notification permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _requestIOSPermissions() async {
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final bool? result = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return result ?? false;
  }

  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      enableVibration: false, // Gentle reminder
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.passive, // Gentle reminder
    );

    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  String _getReminderMessage(CheckinFrequency frequency) {
    switch (frequency) {
      case CheckinFrequency.daily:
        return 'Time for your daily weight check-in! Track your progress.';
      case CheckinFrequency.weekly:
        return 'Weekly weight check-in time! See how you\'re doing.';
      case CheckinFrequency.biweekly:
        return 'Bi-weekly weight check-in reminder. Keep tracking your journey!';
      case CheckinFrequency.monthly:
        return 'Monthly weight check-in time! Update your progress.';
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // This would typically navigate to the weight check-in screen
    // For now, we'll just log the interaction
    print('Weight check-in notification tapped: ${notificationResponse.payload}');
  }

  /// Handle iOS foreground notifications (iOS < 10)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS foreground notifications for older versions
    print('iOS foreground notification received: $title - $body');
  }

  /// Show an in-app notification banner (fallback for when push notifications aren't available)
  void showInAppReminder({
    required CheckinFrequency frequency,
    required Function() onTap,
  }) {
    // This would show an in-app banner or dialog
    // Implementation depends on the app's notification system
    print('Showing in-app weight check-in reminder for $frequency');
    onTap();
  }

  /// Get pending notifications (for debugging/testing)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb || !_isInitialized) {
      return [];
    }

    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Schedule recurring reminders based on frequency
  Future<void> scheduleRecurringReminder({
    required CheckinFrequency frequency,
    required TimeOfDay preferredTime,
  }) async {
    if (kIsWeb || !_isInitialized) {
      return;
    }

    final now = DateTime.now();
    DateTime nextReminder;

    switch (frequency) {
      case CheckinFrequency.daily:
        nextReminder = DateTime(
          now.year,
          now.month,
          now.day,
          preferredTime.hour,
          preferredTime.minute,
        );
        if (nextReminder.isBefore(now)) {
          nextReminder = nextReminder.add(const Duration(days: 1));
        }
        break;
      case CheckinFrequency.weekly:
        nextReminder = DateTime(
          now.year,
          now.month,
          now.day,
          preferredTime.hour,
          preferredTime.minute,
        );
        // Schedule for next week same day
        nextReminder = nextReminder.add(Duration(days: 7 - now.weekday + 1));
        break;
      case CheckinFrequency.biweekly:
        nextReminder = DateTime(
          now.year,
          now.month,
          now.day,
          preferredTime.hour,
          preferredTime.minute,
        );
        nextReminder = nextReminder.add(const Duration(days: 14));
        break;
      case CheckinFrequency.monthly:
        nextReminder = DateTime(
          now.year,
          now.month + 1,
          now.day,
          preferredTime.hour,
          preferredTime.minute,
        );
        break;
    }

    await scheduleReminder(
      scheduledDate: nextReminder,
      frequency: frequency,
    );
  }
}