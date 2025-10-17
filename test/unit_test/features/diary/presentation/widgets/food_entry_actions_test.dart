import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/diary/presentation/widgets/food_entry_actions.dart';

void main() {
  group('FoodEntryActions', () {
    late IntakeEntity testIntake;
    late DateTime testDate;

    setUp(() {
      testIntake = IntakeEntity(
        id: 'test-id',
        meal: MealEntity.empty(),
        amount: 100,
        unit: 'g',
        type: IntakeTypeEntity.breakfast,
        dateTime: DateTime.now(),
      );
      testDate = DateTime.now();
    });

    test('getAvailableActions returns consistent actions for all dates', () {
      // Test for today
      final todayActions = FoodEntryActions.getAvailableActions(testIntake, DateTime.now());
      
      // Test for yesterday
      final yesterdayActions = FoodEntryActions.getAvailableActions(
        testIntake, 
        DateTime.now().subtract(const Duration(days: 1))
      );
      
      // Test for future date
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

    test('action icons are correct', () {
      // Test that action icons are returned correctly
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.editDetails), equals(Icons.edit));
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.copyToAnotherDay), equals(Icons.copy));
      expect(FoodEntryActions.getActionIcon(FoodEntryAction.delete), equals(Icons.delete));
    });

    test('action titles are correct', () {
      expect(FoodEntryActions.getAvailableActions(testIntake, testDate).length, equals(3));
      
      // Test that we have the expected actions
      final actions = FoodEntryActions.getAvailableActions(testIntake, testDate);
      expect(actions, contains(FoodEntryAction.editDetails));
      expect(actions, contains(FoodEntryAction.copyToAnotherDay));
      expect(actions, contains(FoodEntryAction.delete));
    });
  });
}