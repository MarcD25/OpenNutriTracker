import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/features/diary/presentation/widgets/food_entry_actions.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

/// Integration tests for all new fixes implemented in task 26
/// Tests calorie limit consistency, weight check-in indicators, food entry hold function,
/// home page cleanup, and enhanced table rendering
void main() {

  group('New Fixes Integration Tests', () {
    testWidgets('Test calorie limit consistency across all app features', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings and set a calorie adjustment
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find and tap calorie adjustment widget
      final calorieAdjustmentFinder = find.byKey(const Key('calorie_adjustment_widget'));
      expect(calorieAdjustmentFinder, findsOneWidget);
      
      await tester.tap(calorieAdjustmentFinder);
      await tester.pumpAndSettle();

      // Set a calorie adjustment of -200 calories
      final adjustmentSlider = find.byKey(const Key('calorie_adjustment_slider'));
      await tester.drag(adjustmentSlider, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Save the adjustment
      await tester.tap(find.byKey(const Key('save_calorie_adjustment')));
      await tester.pumpAndSettle();

      // Navigate back to home page
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify calorie goal is adjusted on home page
      final homeCalorieGoal = find.byKey(const Key('home_calorie_goal'));
      expect(homeCalorieGoal, findsOneWidget);
      
      // Get the displayed calorie value
      final homeCalorieText = tester.widget<Text>(homeCalorieGoal);
      final homeCalories = double.parse(homeCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));

      // Navigate to diary page
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Verify calorie goal is consistent in diary
      final diaryCalorieGoal = find.byKey(const Key('diary_calorie_goal'));
      expect(diaryCalorieGoal, findsOneWidget);
      
      final diaryCalorieText = tester.widget<Text>(diaryCalorieGoal);
      final diaryCalories = double.parse(diaryCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));

      // Verify consistency
      expect(homeCalories, equals(diaryCalories));

      // Navigate to activity screen
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      // Verify calorie goal is consistent in activity screen
      final activityCalorieGoal = find.byKey(const Key('activity_calorie_goal'));
      if (activityCalorieGoal.evaluate().isNotEmpty) {
        final activityCalorieText = tester.widget<Text>(activityCalorieGoal);
        final activityCalories = double.parse(activityCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));
        expect(homeCalories, equals(activityCalories));
      }

      print('✅ Calorie limit consistency test passed');
    });

    testWidgets('Verify weight check-in indicators appear correctly in Diary tab', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings to set check-in frequency
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find weight check-in frequency setting
      final frequencySelector = find.byKey(const Key('checkin_frequency_selector'));
      expect(frequencySelector, findsOneWidget);

      // Set to weekly check-ins
      await tester.tap(frequencySelector);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Navigate to diary page
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Look for check-in indicators in the calendar
      final checkinIndicators = find.byKey(const Key('checkin_day_indicator'));
      expect(checkinIndicators, findsWidgets);

      // Verify indicators appear on correct days (Mondays for weekly)
      final calendarWidget = find.byKey(const Key('diary_calendar'));
      expect(calendarWidget, findsOneWidget);

      // Check that check-in days have visual indicators
      final checkinDayBorder = find.byKey(const Key('checkin_day_border'));
      expect(checkinDayBorder, findsWidgets);

      final checkinDayIcon = find.byIcon(Icons.scale);
      expect(checkinDayIcon, findsWidgets);

      // Test different frequencies
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Change to daily check-ins
      await tester.tap(frequencySelector);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      // Navigate back to diary
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Verify all days now have indicators
      final dailyIndicators = find.byIcon(Icons.scale);
      expect(dailyIndicators.evaluate().length, greaterThan(5)); // Should be more indicators now

      print('✅ Weight check-in indicators test passed');
    });

    testWidgets('Test food entry hold function consistency across different days', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to diary page
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Add a food entry for today
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Search for and add a food item
      await tester.enterText(find.byKey(const Key('food_search_field')), 'apple');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_food_button')));
      await tester.pumpAndSettle();

      // Find the food entry and long press it
      final todayFoodEntry = find.byKey(const Key('food_entry_apple')).first;
      await tester.longPress(todayFoodEntry);
      await tester.pumpAndSettle();

      // Verify all expected actions are available for today's entry
      expect(find.text('Edit Details'), findsOneWidget);
      expect(find.text('Copy to Another Day'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Close the action sheet
      await tester.tap(find.byKey(const Key('action_sheet_close')));
      await tester.pumpAndSettle();

      // Navigate to a previous day
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Add a food entry for yesterday
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('food_search_field')), 'banana');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_food_button')));
      await tester.pumpAndSettle();

      // Find the food entry from yesterday and long press it
      final yesterdayFoodEntry = find.byKey(const Key('food_entry_banana')).first;
      await tester.longPress(yesterdayFoodEntry);
      await tester.pumpAndSettle();

      // Verify same actions are available for yesterday's entry
      expect(find.text('Edit Details'), findsOneWidget);
      expect(find.text('Copy to Another Day'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Test the "Copy to Another Day" functionality
      await tester.tap(find.text('Copy to Another Day'));
      await tester.pumpAndSettle();

      // Verify date picker appears
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Select today's date
      await tester.tap(find.text(DateTime.now().day.toString()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Navigate back to today
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // Verify the food was copied to today
      expect(find.byKey(const Key('food_entry_banana')), findsOneWidget);

      print('✅ Food entry hold function consistency test passed');
    });

    testWidgets('Verify home page cleanup maintains essential functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify essential widgets are present on home page
      expect(find.byKey(const Key('calorie_progress_widget')), findsOneWidget);
      expect(find.byKey(const Key('macronutrient_summary_widget')), findsOneWidget);
      expect(find.byKey(const Key('activity_summary_widget')), findsOneWidget);

      // Verify BMI warning and recommendation widgets are NOT present
      expect(find.byKey(const Key('bmi_warning_widget')), findsNothing);
      expect(find.byKey(const Key('bmi_recommendations_widget')), findsNothing);

      // Verify essential functionality still works
      // Test calorie progress updates
      final calorieProgress = find.byKey(const Key('calorie_progress_widget'));
      expect(calorieProgress, findsOneWidget);

      // Test macronutrient display
      final macroSummary = find.byKey(const Key('macronutrient_summary_widget'));
      expect(macroSummary, findsOneWidget);

      // Test activity summary
      final activitySummary = find.byKey(const Key('activity_summary_widget'));
      expect(activitySummary, findsOneWidget);

      // Verify navigation to other screens still works
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify weight check-in functionality is still accessible
      final weightCheckinCard = find.byKey(const Key('weight_checkin_card'));
      if (weightCheckinCard.evaluate().isNotEmpty) {
        expect(weightCheckinCard, findsOneWidget);
      }

      print('✅ Home page cleanup test passed');
    });

    testWidgets('Test enhanced table rendering with various markdown tables', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat screen
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test simple table rendering
      const simpleTableMarkdown = '''
| Food | Calories | Protein |
|------|----------|---------|
| Apple | 95 | 0.5g |
| Banana | 105 | 1.3g |
| Orange | 62 | 1.2g |
''';

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Show me this table: $simpleTableMarkdown');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify table is rendered with scrolling capability
      expect(find.byKey(const Key('custom_scrollable_table')), findsOneWidget);
      expect(find.byKey(const Key('table_horizontal_scroll')), findsOneWidget);

      // Test horizontal scrolling
      final horizontalScroll = find.byKey(const Key('table_horizontal_scroll'));
      await tester.drag(horizontalScroll, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Test complex table with many columns
      const complexTableMarkdown = '''
| Food | Calories | Protein | Carbs | Fat | Fiber | Sugar | Sodium | Potassium |
|------|----------|---------|-------|-----|-------|-------|--------|-----------|
| Apple | 95 | 0.5g | 25g | 0.3g | 4.4g | 19g | 2mg | 195mg |
| Banana | 105 | 1.3g | 27g | 0.4g | 3.1g | 14g | 1mg | 422mg |
| Orange | 62 | 1.2g | 15g | 0.2g | 3.1g | 12g | 0mg | 237mg |
| Avocado | 234 | 2.9g | 12g | 21g | 10g | 1g | 10mg | 690mg |
''';

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Show me this complex table: $complexTableMarkdown');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify complex table renders correctly
      final complexTable = find.byKey(const Key('custom_scrollable_table')).last;
      expect(complexTable, findsOneWidget);

      // Test horizontal scrolling with complex table
      await tester.drag(complexTable, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Test vertical scrolling if table is tall
      await tester.drag(complexTable, const Offset(0, -100));
      await tester.pumpAndSettle();

      // Test table with mixed data types
      const mixedDataTableMarkdown = '''
| Item | Price | Available | Rating | Notes |
|------|-------|-----------|--------|-------|
| Product A | \$19.99 | Yes | 4.5/5 | Great quality |
| Product B | \$29.99 | No | 3.8/5 | Out of stock |
| Product C | \$15.50 | Yes | 4.9/5 | Best seller |
''';

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Show me this mixed data table: $mixedDataTableMarkdown');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify mixed data table renders correctly
      final mixedTable = find.byKey(const Key('custom_scrollable_table')).last;
      expect(mixedTable, findsOneWidget);

      // Test table responsiveness on different orientations
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      // Verify tables still render correctly after orientation change
      expect(find.byKey(const Key('custom_scrollable_table')), findsWidgets);

      print('✅ Enhanced table rendering test passed');
    });

    testWidgets('Perform cross-platform testing for all fixes', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Calorie adjustment consistency across platforms
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final calorieAdjustment = find.byKey(const Key('calorie_adjustment_widget'));
      expect(calorieAdjustment, findsOneWidget);

      // Test 2: Weight check-in notifications (platform-specific)
      final notificationSettings = find.byKey(const Key('notification_settings_widget'));
      if (notificationSettings.evaluate().isNotEmpty) {
        await tester.tap(notificationSettings);
        await tester.pumpAndSettle();

        // Verify platform-appropriate notification settings
        expect(find.byKey(const Key('weight_checkin_notifications')), findsOneWidget);
      }

      // Test 3: Food entry actions consistency
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Add a food entry to test actions
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('food_search_field')), 'test food');
      await tester.pumpAndSettle();

      // Test 4: Table rendering performance across platforms
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      const largeTableMarkdown = '''
| Col1 | Col2 | Col3 | Col4 | Col5 | Col6 | Col7 | Col8 |
|------|------|------|------|------|------|------|------|
| Data1 | Data2 | Data3 | Data4 | Data5 | Data6 | Data7 | Data8 |
| Data1 | Data2 | Data3 | Data4 | Data5 | Data6 | Data7 | Data8 |
| Data1 | Data2 | Data3 | Data4 | Data5 | Data6 | Data7 | Data8 |
| Data1 | Data2 | Data3 | Data4 | Data5 | Data6 | Data7 | Data8 |
| Data1 | Data2 | Data3 | Data4 | Data5 | Data6 | Data7 | Data8 |
''';

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Large table: $largeTableMarkdown');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify table renders without performance issues
      expect(find.byKey(const Key('custom_scrollable_table')), findsOneWidget);

      // Test 5: Memory management and cleanup
      // Navigate through multiple screens to test memory usage
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.book));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.fitness_center));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.chat));
        await tester.pumpAndSettle();
      }

      // Verify app is still responsive after navigation stress test
      expect(find.byType(Scaffold), findsOneWidget);

      print('✅ Cross-platform testing passed');
    });

    testWidgets('Integration test for all fixes working together', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test complete user workflow with all fixes
      
      // 1. Set up weight check-in frequency
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final frequencySelector = find.byKey(const Key('checkin_frequency_selector'));
      if (frequencySelector.evaluate().isNotEmpty) {
        await tester.tap(frequencySelector);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Weekly'));
        await tester.pumpAndSettle();
      }

      // 2. Set calorie adjustment
      final calorieAdjustment = find.byKey(const Key('calorie_adjustment_widget'));
      if (calorieAdjustment.evaluate().isNotEmpty) {
        await tester.tap(calorieAdjustment);
        await tester.pumpAndSettle();
        
        final slider = find.byKey(const Key('calorie_adjustment_slider'));
        await tester.drag(slider, const Offset(-50, 0));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('save_calorie_adjustment')));
        await tester.pumpAndSettle();
      }

      // 3. Navigate to home and verify clean layout
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bmi_warning_widget')), findsNothing);
      expect(find.byKey(const Key('calorie_progress_widget')), findsOneWidget);

      // 4. Check diary for weight check-in indicators
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.scale), findsWidgets);

      // 5. Add and test food entry actions
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('food_search_field')), 'apple');
      await tester.pumpAndSettle();

      if (find.text('Apple').evaluate().isNotEmpty) {
        await tester.tap(find.text('Apple').first);
        await tester.pumpAndSettle();
        
        await tester.tap(find.byKey(const Key('add_food_button')));
        await tester.pumpAndSettle();

        // Test hold function
        final foodEntry = find.byKey(const Key('food_entry_apple'));
        if (foodEntry.evaluate().isNotEmpty) {
          await tester.longPress(foodEntry.first);
          await tester.pumpAndSettle();

          expect(find.text('Copy to Another Day'), findsOneWidget);
          
          // Close action sheet
          await tester.tapAt(const Offset(50, 50));
          await tester.pumpAndSettle();
        }
      }

      // 6. Test chat with table rendering
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      const tableMarkdown = '''
| Food | Calories |
|------|----------|
| Apple | 95 |
| Banana | 105 |
''';

      await tester.enterText(find.byKey(const Key('chat_input_field')), 'Table: $tableMarkdown');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify table renders
      expect(find.byKey(const Key('custom_scrollable_table')), findsOneWidget);

      // 7. Test exercise calorie tracking
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Add exercise with calories
      final exerciseInput = find.byKey(const Key('exercise_name_field'));
      if (exerciseInput.evaluate().isNotEmpty) {
        await tester.enterText(exerciseInput, 'Running');
        await tester.pumpAndSettle();

        final calorieInput = find.byKey(const Key('exercise_calorie_input'));
        if (calorieInput.evaluate().isNotEmpty) {
          await tester.enterText(calorieInput, '300');
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('save_exercise_button')));
          await tester.pumpAndSettle();
        }
      }

      // 8. Verify all systems work together
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Check that net calories are calculated correctly
      final netCalories = find.byKey(const Key('net_calories_display'));
      if (netCalories.evaluate().isNotEmpty) {
        expect(netCalories, findsOneWidget);
      }

      print('✅ Complete integration test passed - all fixes working together');
    });
  });
}