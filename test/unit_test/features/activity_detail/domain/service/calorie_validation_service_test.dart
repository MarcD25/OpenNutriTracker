import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/features/activity_detail/domain/service/calorie_validation_service.dart';
import '../../../../../fixture/user_entity_fixtures.dart';

void main() {
  group('CalorieValidationService', () {
    late PhysicalActivityEntity testActivity;

    setUp(() {
      testActivity = const PhysicalActivityEntity(
        'TEST001',
        'Test Activity',
        'A test activity for validation',
        8.0,
        ['test'],
        PhysicalActivityTypeEntity.sport,
      );
    });

    test('should validate reasonable calorie values', () {
      final result = CalorieValidationService.validateCalories(
        calories: 300,
        durationMinutes: 30,
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
      );

      expect(result.isValid, true);
      expect(result.severity, ValidationSeverity.none);
    });

    test('should warn about high calorie values', () {
      final result = CalorieValidationService.validateCalories(
        calories: 900,
        durationMinutes: 30,
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
      );

      expect(result.isValid, true);
      expect(result.severity, ValidationSeverity.warning);
      expect(result.message, contains('High calorie burn'));
    });

    test('should error on extremely high calorie values', () {
      final result = CalorieValidationService.validateCalories(
        calories: 1200,
        durationMinutes: 30,
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.error);
      expect(result.message, contains('extremely high'));
    });

    test('should warn about low calorie values', () {
      final result = CalorieValidationService.validateCalories(
        calories: 15,
        durationMinutes: 30,
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.warning);
      expect(result.message, contains('seem low'));
    });

    test('should calculate recommended calories correctly', () {
      final calories = CalorieValidationService.calculateRecommendedCalories(
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
        durationMinutes: 30,
        intensityMultiplier: 1.0,
      );

      // Expected: 8.0 METs * 80 kg * 0.5 hours = 320 calories
      expect(calories, closeTo(320, 1));
    });

    test('should apply intensity multiplier correctly', () {
      final lightCalories = CalorieValidationService.calculateRecommendedCalories(
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
        durationMinutes: 30,
        intensityMultiplier: 0.8,
      );

      final vigorousCalories = CalorieValidationService.calculateRecommendedCalories(
        user: UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        activity: testActivity,
        durationMinutes: 30,
        intensityMultiplier: 1.3,
      );

      expect(vigorousCalories, greaterThan(lightCalories));
      expect(vigorousCalories / lightCalories, closeTo(1.3 / 0.8, 0.1));
    });
  });
}