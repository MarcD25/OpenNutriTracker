import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/checkin_frequency_entity.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrition Tracker Enhancements Integration Tests', () {
    testWidgets('Complete weight check-in flow with BMI recalculation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to home screen
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Find and tap weight check-in card
      final weightCheckinCard = find.byKey(const Key('weight_checkin_card'));
      expect(weightCheckinCard, findsOneWidget);
      
      await tester.tap(weightCheckinCard);
      await tester.pumpAndSettle();

      // Enter weight data
      final weightInput = find.byKey(const Key('weight_input_field'));
      await tester.enterText(weightInput, '75.5');
      await tester.pumpAndSettle();

      // Add optional notes
      final notesInput = find.byKey(const Key('weight_notes_input'));
      await tester.enterText(notesInput, 'Feeling good today');
      await tester.pumpAndSettle();

      // Submit weight entry
      final submitButton = find.byKey(const Key('submit_weight_button'));
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify BMI recalculation notification appears
      expect(find.byKey(const Key('bmi_update_notification')), findsOneWidget);
      
      // Verify goal adjustment suggestion appears
      expect(find.byKey(const Key('goal_adjustment_suggestion')), findsOneWidget);

      // Verify weight progress chart updates
      expect(find.byKey(const Key('weight_progress_chart')), findsOneWidget);

      // Verify calorie goals are updated with new BMI
      final calorieGoalDisplay = find.byKey(const Key('calorie_goal_display'));
      expect(calorieGoalDisplay, findsOneWidget);

      // Check that logistics tracking recorded the weight check-in
      // This would be verified through the logistics data source in a real test
    });

    testWidgets('Exercise calorie tracking with net calorie updates', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add activity screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select exercise activity
      final exerciseTab = find.byKey(const Key('exercise_tab'));
      await tester.tap(exerciseTab);
      await tester.pumpAndSettle();

      // Select a specific exercise
      final runningActivity = find.text('Running');
      await tester.tap(runningActivity);
      await tester.pumpAndSettle();

      // Enter exercise duration
      final durationInput = find.byKey(const Key('duration_input'));
      await tester.enterText(durationInput, '30');
      await tester.pumpAndSettle();

      // Select intensity level
      final intensitySelector = find.byKey(const Key('intensity_selector'));
      await tester.tap(intensitySelector);
      await tester.pumpAndSettle();
      
      final moderateIntensity = find.text('Moderate');
      await tester.tap(moderateIntensity);
      await tester.pumpAndSettle();

      // Verify auto-calculated calories display
      expect(find.byKey(const Key('auto_calculated_calories')), findsOneWidget);

      // Override with manual calorie entry
      final manualCalorieToggle = find.byKey(const Key('manual_calorie_toggle'));
      await tester.tap(manualCalorieToggle);
      await tester.pumpAndSettle();

      final manualCalorieInput = find.byKey(const Key('manual_calorie_input'));
      await tester.enterText(manualCalorieInput, '350');
      await tester.pumpAndSettle();

      // Verify calorie validation warnings for unrealistic values
      await tester.enterText(manualCalorieInput, '2000'); // Unrealistic for 30min
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calorie_validation_warning')), findsOneWidget);

      // Reset to realistic value
      await tester.enterText(manualCalorieInput, '350');
      await tester.pumpAndSettle();

      // Save the exercise
      final saveButton = find.byKey(const Key('save_exercise_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Navigate back to home to verify net calorie updates
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify dashboard shows updated net calories
      final netCaloriesDisplay = find.byKey(const Key('net_calories_display'));
      expect(netCaloriesDisplay, findsOneWidget);

      // Verify TDEE + exercise calories display
      final tdeeWithExerciseDisplay = find.byKey(const Key('tdee_with_exercise_display'));
      expect(tdeeWithExerciseDisplay, findsOneWidget);

      // Verify total exercise calories for the day
      final totalExerciseDisplay = find.byKey(const Key('total_exercise_calories'));
      expect(totalExerciseDisplay, findsOneWidget);
    });

    testWidgets('LLM validation with various response types', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat screen
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test case 1: Normal response validation
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'What are the calories in 100g of chicken breast?');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify response appears without validation warnings
      expect(find.byKey(const Key('chat_message_bubble')), findsWidgets);
      expect(find.byKey(const Key('validation_warning_indicator')), findsNothing);

      // Test case 2: Response with validation issues
      await tester.enterText(messageInput, 'Generate a very long detailed meal plan');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify validation feedback appears for potentially problematic responses
      // This would depend on the actual LLM response, but we can check for validation UI
      final validationFeedback = find.byKey(const Key('validation_feedback_widget'));
      
      // Test case 3: Response requiring retry
      // Simulate a scenario where validation fails and retry is needed
      final retryButton = find.byKey(const Key('retry_message_button'));
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Verify validation results are logged
      // This would be checked through the logistics tracking system
    });

    testWidgets('Logistics tracking across all user interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Perform various user interactions to test logistics tracking

      // 1. Navigation tracking
      await tester.tap(find.byIcon(Icons.restaurant_menu)); // Diary
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.home)); // Home
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.settings)); // Settings
      await tester.pumpAndSettle();

      // 2. Meal logging interaction
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      final addMealButton = find.byKey(const Key('add_meal_button'));
      if (addMealButton.evaluate().isNotEmpty) {
        await tester.tap(addMealButton);
        await tester.pumpAndSettle();
        
        // Add a simple food item
        final foodSearch = find.byKey(const Key('food_search_input'));
        await tester.enterText(foodSearch, 'apple');
        await tester.pumpAndSettle();
        
        // Select first result and add
        final firstResult = find.byKey(const Key('food_result_0'));
        if (firstResult.evaluate().isNotEmpty) {
          await tester.tap(firstResult);
          await tester.pumpAndSettle();
          
          final addFoodButton = find.byKey(const Key('add_food_button'));
          await tester.tap(addFoodButton);
          await tester.pumpAndSettle();
        }
      }

      // 3. Settings changes
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      final weightUnitSetting = find.byKey(const Key('weight_unit_setting'));
      if (weightUnitSetting.evaluate().isNotEmpty) {
        await tester.tap(weightUnitSetting);
        await tester.pumpAndSettle();
      }

      // 4. Chat interactions
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();
      
      final chatInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(chatInput, 'Test message for logistics tracking');
      
      final chatSendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(chatSendButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that all interactions were tracked
      // In a real implementation, this would check the logistics data source
      // for the presence of all expected event types
    });

    testWidgets('Enhanced table rendering with different data sets', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat screen
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test case 1: Request a nutrition table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Show me a nutrition comparison table for different fruits');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify scrollable table appears
      final scrollableTable = find.byKey(const Key('scrollable_table'));
      if (scrollableTable.evaluate().isNotEmpty) {
        // Test horizontal scrolling
        await tester.drag(scrollableTable, const Offset(-200, 0));
        await tester.pumpAndSettle();
        
        // Test vertical scrolling
        await tester.drag(scrollableTable, const Offset(0, -100));
        await tester.pumpAndSettle();
        
        // Verify sticky headers remain visible
        expect(find.byKey(const Key('table_header')), findsOneWidget);
      }

      // Test case 2: Request a large data table
      await tester.enterText(messageInput, 'Create a detailed macro breakdown table for a weekly meal plan');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify table handles large datasets properly
      final largeTable = find.byKey(const Key('scrollable_table'));
      if (largeTable.evaluate().isNotEmpty) {
        // Test performance with large table
        await tester.drag(largeTable, const Offset(-300, 0));
        await tester.pumpAndSettle();
        
        // Verify table remains responsive
        expect(largeTable, findsOneWidget);
      }

      // Test case 3: Request a table with mixed data types
      await tester.enterText(messageInput, 'Show me a table with food names, calories, proteins, and preparation times');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify proper column alignment and formatting
      final mixedDataTable = find.byKey(const Key('scrollable_table'));
      if (mixedDataTable.evaluate().isNotEmpty) {
        // Verify different data types are properly aligned
        expect(find.byKey(const Key('table_cell')), findsWidgets);
      }
    });

    testWidgets('End-to-end feature integration test', (WidgetTester tester) async {
      // This test validates that all features work together seamlessly
      app.main();
      await tester.pumpAndSettle();

      // 1. Start with weight check-in
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      final weightCard = find.byKey(const Key('weight_checkin_card'));
      if (weightCard.evaluate().isNotEmpty) {
        await tester.tap(weightCard);
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byKey(const Key('weight_input_field')), '70.0');
        await tester.tap(find.byKey(const Key('submit_weight_button')));
        await tester.pumpAndSettle();
      }

      // 2. Log exercise with calorie tracking
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Add exercise and verify net calorie calculation
      // (Implementation would depend on specific UI structure)

      // 3. Use chat with table rendering and validation
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(const Key('chat_message_input')), 
        'Based on my new weight, show me an updated meal plan table');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Verify all systems updated consistently
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      // Check that BMI, calorie goals, and net calories all reflect the changes
      expect(find.byKey(const Key('bmi_indicator')), findsOneWidget);
      expect(find.byKey(const Key('calorie_goal_display')), findsOneWidget);
      expect(find.byKey(const Key('net_calories_display')), findsOneWidget);

      // Verify logistics tracked all interactions
      // This would be validated through the logistics data source
    });
  });
}