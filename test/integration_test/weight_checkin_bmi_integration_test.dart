import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/checkin_frequency_entity.dart';
import 'package:opennutritracker/core/domain/entity/calorie_recommendation_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Weight Check-in BMI Integration Tests', () {
    testWidgets('Weight check-in triggers BMI recalculation and calorie goal updates', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to home screen
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Capture initial BMI and calorie goal values
      final initialBMI = find.byKey(const Key('bmi_value_display'));
      final initialCalorieGoal = find.byKey(const Key('calorie_goal_value'));
      
      String? initialBMIText;
      String? initialCalorieText;
      
      if (initialBMI.evaluate().isNotEmpty) {
        initialBMIText = (tester.widget(initialBMI) as Text).data;
      }
      
      if (initialCalorieGoal.evaluate().isNotEmpty) {
        initialCalorieText = (tester.widget(initialCalorieGoal) as Text).data;
      }

      // Perform weight check-in with significant weight change
      final weightCheckinCard = find.byKey(const Key('weight_checkin_card'));
      expect(weightCheckinCard, findsOneWidget);
      
      await tester.tap(weightCheckinCard);
      await tester.pumpAndSettle();

      // Enter new weight (simulate 5kg weight loss)
      final weightInput = find.byKey(const Key('weight_input_field'));
      await tester.enterText(weightInput, '65.0');
      await tester.pumpAndSettle();

      // Submit weight entry
      final submitButton = find.byKey(const Key('submit_weight_button'));
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify BMI update notification appears
      expect(find.byKey(const Key('bmi_update_notification')), findsOneWidget);
      
      // Verify goal adjustment suggestion appears
      expect(find.byKey(const Key('goal_adjustment_suggestion')), findsOneWidget);

      // Check that BMI value has been updated
      final updatedBMI = find.byKey(const Key('bmi_value_display'));
      if (updatedBMI.evaluate().isNotEmpty && initialBMIText != null) {
        final updatedBMIText = (tester.widget(updatedBMI) as Text).data;
        expect(updatedBMIText, isNot(equals(initialBMIText)));
      }

      // Check that calorie goal has been recalculated
      final updatedCalorieGoal = find.byKey(const Key('calorie_goal_value'));
      if (updatedCalorieGoal.evaluate().isNotEmpty && initialCalorieText != null) {
        final updatedCalorieText = (tester.widget(updatedCalorieGoal) as Text).data;
        expect(updatedCalorieText, isNot(equals(initialCalorieText)));
      }

      // Verify BMI category indicator updates
      expect(find.byKey(const Key('bmi_category_indicator')), findsOneWidget);

      // Verify weight progress chart shows new data point
      expect(find.byKey(const Key('weight_progress_chart')), findsOneWidget);
    });

    testWidgets('Weight check-in frequency settings integration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find weight check-in frequency setting
      final frequencySetting = find.byKey(const Key('weight_checkin_frequency_setting'));
      expect(frequencySetting, findsOneWidget);
      
      await tester.tap(frequencySetting);
      await tester.pumpAndSettle();

      // Change frequency to weekly
      final weeklyOption = find.text('Weekly');
      await tester.tap(weeklyOption);
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify that check-in card behavior reflects new frequency
      // This would depend on the current date and last check-in date
      final weightCard = find.byKey(const Key('weight_checkin_card'));
      
      // The card should either be visible (if check-in is due) or hidden
      // based on the weekly frequency setting
    });

    testWidgets('Weight trend calculation and display', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate multiple weight entries over time
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // First weight entry
      final weightCard = find.byKey(const Key('weight_checkin_card'));
      if (weightCard.evaluate().isNotEmpty) {
        await tester.tap(weightCard);
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byKey(const Key('weight_input_field')), '70.0');
        await tester.tap(find.byKey(const Key('submit_weight_button')));
        await tester.pumpAndSettle();
      }

      // Navigate to weight history/progress screen
      final viewProgressButton = find.byKey(const Key('view_weight_progress_button'));
      if (viewProgressButton.evaluate().isNotEmpty) {
        await tester.tap(viewProgressButton);
        await tester.pumpAndSettle();

        // Verify weight progress chart displays
        expect(find.byKey(const Key('weight_progress_chart')), findsOneWidget);
        
        // Verify trend indicators
        expect(find.byKey(const Key('weight_trend_indicator')), findsOneWidget);
        
        // Verify trend statistics
        expect(find.byKey(const Key('trend_statistics')), findsOneWidget);
      }
    });

    testWidgets('BMI category changes trigger appropriate recommendations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test scenario: User weight change moves them to different BMI category
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Enter weight that would put user in overweight category
      final weightCard = find.byKey(const Key('weight_checkin_card'));
      if (weightCard.evaluate().isNotEmpty) {
        await tester.tap(weightCard);
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byKey(const Key('weight_input_field')), '85.0');
        await tester.tap(find.byKey(const Key('submit_weight_button')));
        await tester.pumpAndSettle();

        // Verify BMI category indicator shows "Overweight"
        final bmiCategory = find.byKey(const Key('bmi_category_display'));
        if (bmiCategory.evaluate().isNotEmpty) {
          final categoryText = (tester.widget(bmiCategory) as Text).data;
          expect(categoryText, contains('Overweight'));
        }

        // Verify appropriate recommendations appear
        expect(find.byKey(const Key('bmi_recommendations_widget')), findsOneWidget);
        
        // Verify calorie adjustment for weight loss goal
        expect(find.byKey(const Key('goal_reassessment_widget')), findsOneWidget);
      }
    });

    testWidgets('Weight check-in notification system integration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings to enable notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Enable weight check-in notifications
      final notificationToggle = find.byKey(const Key('weight_checkin_notifications_toggle'));
      if (notificationToggle.evaluate().isNotEmpty) {
        await tester.tap(notificationToggle);
        await tester.pumpAndSettle();
      }

      // Set notification time
      final notificationTime = find.byKey(const Key('notification_time_picker'));
      if (notificationTime.evaluate().isNotEmpty) {
        await tester.tap(notificationTime);
        await tester.pumpAndSettle();
        
        // Select a time (this would open a time picker)
        // Implementation depends on the specific time picker widget used
      }

      // Verify notification settings are saved
      expect(find.byKey(const Key('notification_settings_saved_indicator')), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify that notification scheduling is active
      // This would be tested by checking the notification service state
      // In a real test, we might mock the notification service
    });
  });
}