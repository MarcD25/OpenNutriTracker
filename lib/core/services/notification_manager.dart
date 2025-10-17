import 'package:flutter/foundation.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_notification_service.dart';

/// Central notification manager for the app
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  late WeightCheckinNotificationService _weightCheckinService;
  bool _isInitialized = false;

  /// Initialize all notification services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _weightCheckinService = WeightCheckinNotificationService();
      await _weightCheckinService.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification services: $e');
      }
      // Continue without notifications if initialization fails
    }
  }

  /// Get weight check-in notification service
  WeightCheckinNotificationService get weightCheckinService {
    if (!_isInitialized) {
      throw StateError('NotificationManager not initialized. Call initialize() first.');
    }
    return _weightCheckinService;
  }

  /// Request all necessary permissions
  Future<bool> requestAllPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final weightPermission = await _weightCheckinService.requestPermissions();
      return weightPermission;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      return false;
    }
  }

  /// Check if notifications are enabled for the app
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      return await _weightCheckinService.areNotificationsEnabled();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking notification status: $e');
      }
      return false;
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _weightCheckinService.cancelAllReminders();
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling notifications: $e');
      }
    }
  }
}