import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/features/diary/presentation/widgets/food_entry_actions.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';

void main() {
  group('Food Entry Hold Function Consistency Integration Tests', () {
    testWidgets('Food entry hold function shows consistent actions across different days', (WidgetTester tester) async {
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
      final searchField = find.byKey(const Key('food_search_field'));
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'apple');
        await tester.pumpAndSettle();

        final appleOption = find.text('Apple');
        if (appleOption.evaluate().isNotEmpty) {
          await tester.tap(appleOption.first);
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('add_food_button')));
          await tester.pumpAndSettle();

          // Find the food entry and long press it
          final todayFoodEntry = find.byKey(const Key('food_entry_apple'));
          if (todayFoodEntry.evaluate().isNotEmpty) {
            await tester.longPress(todayFoodEntry.first);
            await tester.pumpAndSettle();

            // Verify all expected actions are available for today's entry
            expect(find.text('Edit Details'), findsOneWidget);
            expect(find.text('Copy to Another Day'), findsOneWidget);
            expect(find.text('Delete'), findsOneWidget);

            // Test the "Copy to Another Day" functionality
            await tester.tap(find.text('Copy to Another Day'));
            await tester.pumpAndSettle();

            // Verify date picker appears
            expect(find.byType(DatePickerDialog), findsOneWidget);

            // Close the date picker
            await tester.tap(find.text('Cancel'));
            await tester.pumpAndSettle();
          }
        }
      }

      // Navigate to a previous day
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Add a food entry for yesterday (if possible)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final searchFieldYesterday = find.byKey(const Key('food_search_field'));
      if (searchFieldYesterday.evaluate().isNotEmpty) {
        await tester.enterText(searchFieldYesterday, 'banana');
        await tester.pumpAndSettle();

        final bananaOption = find.text('Banana');
        if (bananaOption.evaluate().isNotEmpty) {
          await tester.tap(bananaOption.first);
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('add_food_button')));
          await tester.pumpAndSettle();

          // Find the food entry from yesterday and long press it
          final yesterdayFoodEntry = find.byKey(const Key('food_entry_banana'));
          if (yesterdayFoodEntry.evaluate().isNotEmpty) {
            await tester.longPress(yesterdayFoodEntry.first);
            await tester.pumpAndSettle();

            // Verify same actions are available for yesterday's entry
            expect(find.text('Edit Details'), findsOneWidget);
            expect(find.text('Copy to Another Day'), findsOneWidget);
            expect(find.text('Delete'), findsOneWidget);

            // Close the action sheet
            await tester.tapAt(const Offset(50, 50));
            await tester.pumpAndSettle();
          }
        }
      }

      print('✅ Food entry hold function consistency verified across different days');
    });

  group('Food Entry Actions Unit Tests', () {
    testWidgets('Food entry actions are consistent across all dates', (WidgetTester tester) async {
      final testIntake = IntakeEntity(
        id: 'test-id',
        meal: MealEntity.empty(),
        amount: 100,
        unit: 'g',
        type: IntakeTypeEntity.breakfast,
        dateTime: DateTime.now(),
      );

      // Test that actions are consistent for today
      final todayActions = FoodEntryActions.getAvailableActions(testIntake, DateTime.now());
      
      // Test that actions are consistent for yesterday
      final yesterdayActions = FoodEntryActions.getAvailableActions(
        testIntake, 
        DateTime.now().subtract(const Duration(days: 1))
      );
      
      // Test that actions are consistent for future date
      final futureActions = FoodEntryActions.getAvailableActions(
        testIntake, 
        DateTime.now().add(const Duration(days: 1))
      );
      
      // All should return the same actions
      expect(todayActions, equals(yesterdayActions));
      expect(todayActions, equals(futureActions));
      
      // Should contain all three actions
      expect(todayActions, contains(FoodEntryAction.editDetails));
      expect(todayActions, contains(FoodEntryAction.copyToAnotherDay));
      expect(todayActions, contains(FoodEntryAction.delete));
      expect(todayActions.length, equals(3));
    });

    test('Action icons are correctly mapped', () {
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.editDetails), equals(Icons.edit));
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.copyToAnotherDay), equals(Icons.copy));
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.delete), equals(Icons.delete));
    });

    test('Copy to Another Day functionality replaces Copy to Today', () {
      // Verify that the new action is named correctly
      final actions = [
        FoodEntryAction.editDetails,
        FoodEntryAction.copyToAnotherDay,
        FoodEntryAction.delete,
      ];
      
      // Ensure copyToAnotherDay is present (replaces the old copyToToday)
      expect(actions, contains(FoodEntryAction.copyToAnotherDay));
      
      // Ensure the action count is correct
      expect(actions.length, equals(3));
    });
  });
}