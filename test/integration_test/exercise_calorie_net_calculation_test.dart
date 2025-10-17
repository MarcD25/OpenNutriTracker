import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/core/domain/entity/activity_intensity_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercise Calorie Net Calculation Integration Tests', () {
    testWidgets('Exercise logging updates net calorie calculation in real-time', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start at home screen and capture initial values
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Capture initial net calorie values
      final initialNetCalories = find.byKey(const Key('net_calories_display'));
      final initialTDEE = find.byKey(const Key('tdee_display'));
      
      String? initialNetText;
      String? initialTDEEText;
      
      if (initialNetCalories.evaluate().isNotEmpty) {
        initialNetText = (tester.widget(initialNetCalories) as Text).data;
      }
      
      if (initialTDEE.evaluate().isNotEmpty) {
        initialTDEEText = (tester.widget(initialTDEE) as Text).data;
      }

      // Navigate to add activity
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select exercise tab
      final exerciseTab = find.byKey(const Key('exercise_tab'));
      await tester.tap(exerciseTab);
      await tester.pumpAndSettle();

      // Select running activity
      final runningActivity = find.text('Running');
      await tester.tap(runningActivity);
      await tester.pumpAndSettle();

      // Enter exercise details
      final durationInput = find.byKey(const Key('duration_input'));
      await tester.enterText(durationInput, '45');
      await tester.pumpAndSettle();

      // Select intensity
      final intensitySelector = find.byKey(const Key('intensity_selector'));
      await tester.tap(intensitySelector);
      await tester.pumpAndSettle();
      
      final vigorousIntensity = find.text('Vigorous');
      await tester.tap(vigorousIntensity);
      await tester.pumpAndSettle();

      // Verify auto-calculated calories display
      final autoCaloriesDisplay = find.byKey(const Key('auto_calculated_calories'));
      expect(autoCaloriesDisplay, findsOneWidget);

      // Save the exercise
      final saveButton = find.byKey(const Key('save_exercise_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify net calories have been updated
      final updatedNetCalories = find.byKey(const Key('net_calories_display'));
      if (updatedNetCalories.evaluate().isNotEmpty && initialNetText != null) {
        final updatedNetText = (tester.widget(updatedNetCalories) as Text).data;
        expect(updatedNetText, isNot(equals(initialNetText)));
      }

      // Verify TDEE + exercise display
      expect(find.byKey(const Key('tdee_with_exercise_display')), findsOneWidget);

      // Verify total exercise calories for the day
      expect(find.byKey(const Key('total_exercise_calories')), findsOneWidget);
    });

    testWidgets('Multiple exercise entries aggregate correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add first exercise
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      // Add running
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('duration_input')), '30');
      await tester.tap(find.byKey(const Key('save_exercise_button')));
      await tester.pumpAndSettle();

      // Capture calories after first exercise
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final firstExerciseCalories = find.byKey(const Key('total_exercise_calories'));
      String? firstExerciseText;
      if (firstExerciseCalories.evaluate().isNotEmpty) {
        firstExerciseText = (tester.widget(firstExerciseCalories) as Text).data;
      }

      // Add second exercise
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      // Add cycling
      await tester.tap(find.text('Cycling'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('duration_input')), '20');
      await tester.tap(find.byKey(const Key('save_exercise_button')));
      await tester.pumpAndSettle();

      // Verify aggregated calories
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final totalExerciseCalories = find.byKey(const Key('total_exercise_calories'));
      if (totalExerciseCalories.evaluate().isNotEmpty && firstExerciseText != null) {
        final totalExerciseText = (tester.widget(totalExerciseCalories) as Text).data;
        expect(totalExerciseText, isNot(equals(firstExerciseText)));
        
        // The total should be greater than the first exercise alone
        final firstValue = double.tryParse(firstExerciseText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        final totalValue = double.tryParse(totalExerciseText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        expect(totalValue, greaterThan(firstValue));
      }
    });

    testWidgets('Manual calorie override works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add exercise
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weight Training'));
      await tester.pumpAndSettle();

      // Enter duration
      await tester.enterText(find.byKey(const Key('duration_input')), '60');
      await tester.pumpAndSettle();

      // Check auto-calculated value
      final autoCaloriesDisplay = find.byKey(const Key('auto_calculated_calories'));
      expect(autoCaloriesDisplay, findsOneWidget);

      // Enable manual calorie entry
      final manualToggle = find.byKey(const Key('manual_calorie_toggle'));
      await tester.tap(manualToggle);
      await tester.pumpAndSettle();

      // Enter manual calorie value
      final manualInput = find.byKey(const Key('manual_calorie_input'));
      await tester.enterText(manualInput, '400');
      await tester.pumpAndSettle();

      // Save exercise
      await tester.tap(find.byKey(const Key('save_exercise_button')));
      await tester.pumpAndSettle();

      // Verify manual value is used in calculations
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final exerciseCaloriesDisplay = find.byKey(const Key('total_exercise_calories'));
      if (exerciseCaloriesDisplay.evaluate().isNotEmpty) {
        final displayText = (tester.widget(exerciseCaloriesDisplay) as Text).data;
        expect(displayText, contains('400'));
      }
    });

    testWidgets('Calorie validation warnings for unrealistic values', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Walking'));
      await tester.pumpAndSettle();

      // Enter short duration
      await tester.enterText(find.byKey(const Key('duration_input')), '10');
      await tester.pumpAndSettle();

      // Enable manual entry
      await tester.tap(find.byKey(const Key('manual_calorie_toggle')));
      await tester.pumpAndSettle();

      // Enter unrealistically high calories for 10 minutes of walking
      await tester.enterText(find.byKey(const Key('manual_calorie_input')), '1000');
      await tester.pumpAndSettle();

      // Verify validation warning appears
      expect(find.byKey(const Key('calorie_validation_warning')), findsOneWidget);

      // Verify warning message is appropriate
      final warningText = find.byKey(const Key('validation_warning_text'));
      if (warningText.evaluate().isNotEmpty) {
        final warning = (tester.widget(warningText) as Text).data;
        expect(warning, contains('unrealistic'));
      }

      // Test with realistic value
      await tester.enterText(find.byKey(const Key('manual_calorie_input')), '50');
      await tester.pumpAndSettle();

      // Verify warning disappears
      expect(find.byKey(const Key('calorie_validation_warning')), findsNothing);
    });

    testWidgets('Net calorie calculation with meal logging integration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start with exercise logging
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('duration_input')), '30');
      await tester.tap(find.byKey(const Key('save_exercise_button')));
      await tester.pumpAndSettle();

      // Check net calories after exercise
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final netCaloriesAfterExercise = find.byKey(const Key('net_calories_display'));
      String? netAfterExercise;
      if (netCaloriesAfterExercise.evaluate().isNotEmpty) {
        netAfterExercise = (tester.widget(netCaloriesAfterExercise) as Text).data;
      }

      // Add a meal
      final addMealButton = find.byKey(const Key('add_meal_button'));
      if (addMealButton.evaluate().isNotEmpty) {
        await tester.tap(addMealButton);
        await tester.pumpAndSettle();

        // Add food item (simplified - actual implementation would depend on food search)
        final foodSearch = find.byKey(const Key('food_search_input'));
        if (foodSearch.evaluate().isNotEmpty) {
          await tester.enterText(foodSearch, 'banana');
          await tester.pumpAndSettle();

          final firstResult = find.byKey(const Key('food_result_0'));
          if (firstResult.evaluate().isNotEmpty) {
            await tester.tap(firstResult);
            await tester.pumpAndSettle();

            await tester.tap(find.byKey(const Key('add_food_button')));
            await tester.pumpAndSettle();
          }
        }
      }

      // Check net calories after meal
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final netCaloriesAfterMeal = find.byKey(const Key('net_calories_display'));
      if (netCaloriesAfterMeal.evaluate().isNotEmpty && netAfterExercise != null) {
        final netAfterMeal = (tester.widget(netCaloriesAfterMeal) as Text).data;
        expect(netAfterMeal, isNot(equals(netAfterExercise)));
      }

      // Verify the calculation shows: TDEE + exercise - food calories
      expect(find.byKey(const Key('calorie_breakdown_display')), findsOneWidget);
    });

    testWidgets('TDEE integration with exercise calories', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial TDEE display
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final baseTDEE = find.byKey(const Key('base_tdee_display'));
      expect(baseTDEE, findsOneWidget);

      // Add exercise
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('exercise_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Swimming'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('duration_input')), '45');
      await tester.tap(find.byKey(const Key('save_exercise_button')));
      await tester.pumpAndSettle();

      // Verify TDEE + exercise display
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final tdeeWithExercise = find.byKey(const Key('tdee_with_exercise_display'));
      expect(tdeeWithExercise, findsOneWidget);

      // Verify the combined value is greater than base TDEE
      if (baseTDEE.evaluate().isNotEmpty && tdeeWithExercise.evaluate().isNotEmpty) {
        final baseValue = (tester.widget(baseTDEE) as Text).data;
        final combinedValue = (tester.widget(tdeeWithExercise) as Text).data;
        
        final baseNum = double.tryParse(baseValue?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
        final combinedNum = double.tryParse(combinedValue?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
        
        expect(combinedNum, greaterThan(baseNum));
      }
    });
  });
}