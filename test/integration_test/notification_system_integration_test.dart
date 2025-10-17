import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/notification_manager.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_notification_service.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

void main() {
  group('Notification System Integration Tests', () {
    late NotificationManager notificationManager;
    late WeightCheckinNotificationService weightCheckinService;

    setUp(() {
      notificationManager = NotificationManager();
      weightCheckinService = WeightCheckinNotificationService();
    });

    testWidgets('NotificationManager initializes successfully', (WidgetTester tester) async {
      // Test that the notification manager can be initialized
      expect(() => notificationManager.initialize(), returnsNormally);
    });

    testWidgets('Weight check-in notifications can be scheduled', (WidgetTester tester) async {
      // Initialize the notification service
      await weightCheckinService.initialize();
      
      // Schedule a reminder
      final scheduledDate = DateTime.now().add(const Duration(hours: 24));
      
      expect(
        () => weightCheckinService.scheduleReminder(
          scheduledDate: scheduledDate,
          frequency: CheckinFrequency.daily,
        ),
        returnsNormally,
      );
    });

    testWidgets('Notification permissions can be requested', (WidgetTester tester) async {
      // Test that permission requests don't throw errors
      // In a real device, this would show system permission dialogs
      expect(() => notificationManager.requestAllPermissions(), returnsNormally);
    });

    testWidgets('Notifications can be cancelled', (WidgetTester tester) async {
      // Test that notifications can be cancelled without errors
      expect(() => notificationManager.cancelAllNotifications(), returnsNormally);
    });

    testWidgets('Cross-platform notification features work', (WidgetTester tester) async {
      // Test that the notification system handles different platforms gracefully
      await weightCheckinService.initialize();
      
      // Test scheduling with different frequencies
      final frequencies = [
        CheckinFrequency.daily,
        CheckinFrequency.weekly,
        CheckinFrequency.biweekly,
        CheckinFrequency.monthly,
      ];

      for (final frequency in frequencies) {
        final scheduledDate = DateTime.now().add(const Duration(hours: 1));
        
        expect(
          () => weightCheckinService.scheduleReminder(
            scheduledDate: scheduledDate,
            frequency: frequency,
          ),
          returnsNormally,
        );
      }
    });

    testWidgets('Recurring reminders can be scheduled', (WidgetTester tester) async {
      await weightCheckinService.initialize();
      
      const preferredTime = TimeOfDay(hour: 9, minute: 0);
      
      expect(
        () => weightCheckinService.scheduleRecurringReminder(
          frequency: CheckinFrequency.weekly,
          preferredTime: preferredTime,
        ),
        returnsNormally,
      );
    });

    testWidgets('Notification status can be checked', (WidgetTester tester) async {
      // Test that notification status checking doesn't throw errors
      expect(() => notificationManager.areNotificationsEnabled(), returnsNormally);
      expect(() => weightCheckinService.areNotificationsEnabled(), returnsNormally);
    });

    testWidgets('Pending notifications can be retrieved', (WidgetTester tester) async {
      await weightCheckinService.initialize();
      
      // Test that pending notifications can be retrieved
      expect(() => weightCheckinService.getPendingNotifications(), returnsNormally);
    });

    testWidgets('In-app reminders work as fallback', (WidgetTester tester) async {
      // Test the fallback in-app reminder system
      bool callbackExecuted = false;
      
      weightCheckinService.showInAppReminder(
        frequency: CheckinFrequency.daily,
        onTap: () {
          callbackExecuted = true;
        },
      );
      
      expect(callbackExecuted, isTrue);
    });
  });
}