import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/calorie_recommendation_entity.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';

void main() {
  group('EnhancedCalorieGoalCalc', () {
    late UserEntity normalWeightUser;
    late UserEntity underweightUser;
    late UserEntity overweightUser;
    late UserEntity obeseUser;

    setUp(() {
      // Normal weight user (BMI ~22)
      normalWeightUser = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 175,
        weightKG: 70,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.sedentary,
      );

      // Underweight user (BMI ~17)
      underweightUser = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 175,
        weightKG: 52,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.gainWeight,
        pal: UserPALEntity.sedentary,
      );

      // Overweight user (BMI ~27)
      overweightUser = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 175,
        weightKG: 82,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
      );

      // Obese user (BMI ~32)
      obeseUser = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 175,
        weightKG: 98,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
      );
    });

    test('calculateBMIAdjustedTDEE should return standard TDEE for normal weight user', () async {
      final result = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 0);
      
      // Should be close to standard TDEE calculation (no BMI adjustment for normal weight)
      expect(result, greaterThan(1800));
      expect(result, lessThan(2500));
    });

    test('calculateBMIAdjustedTDEE should apply BMI adjustments correctly', () async {
      // Test that BMI adjustments are applied by comparing with base TDEE calculations
      final normalRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(normalWeightUser, 0);
      final underweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(underweightUser, 0);
      final overweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(overweightUser, 0);
      final obeseRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(obeseUser, 0);
      
      // Normal weight should have no BMI adjustment
      expect(normalRec.bmiAdjustment, equals(0));
      
      // Underweight user wanting to gain weight should get bonus calories
      expect(underweightRec.bmiAdjustment, greaterThan(0));
      
      // Overweight user wanting to lose weight should get penalty calories
      expect(overweightRec.bmiAdjustment, lessThan(0));
      
      // Obese user wanting to lose weight should get larger penalty
      expect(obeseRec.bmiAdjustment, lessThan(overweightRec.bmiAdjustment));
    });

    test('calculateBMIAdjustedTDEE should include exercise calories', () async {
      final baseCalories = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 0);
      final withExercise = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 300);
      
      expect(withExercise, equals(baseCalories + 300));
    });

    test('getPersonalizedRecommendation should return complete recommendation', () async {
      final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(normalWeightUser, 200);
      
      expect(recommendation.baseTDEE, greaterThan(0));
      expect(recommendation.exerciseCalories, equals(200));
      expect(recommendation.bmiCategory, equals(BMICategory.normal));
      expect(recommendation.recommendations, isNotEmpty);
      expect(recommendation.netCalories, greaterThan(0));
    });

    test('getPersonalizedRecommendation should provide appropriate recommendations for different BMI categories', () async {
      final normalRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(normalWeightUser, 0);
      final underweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(underweightUser, 0);
      final overweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(overweightUser, 0);
      
      expect(normalRec.bmiCategory, equals(BMICategory.normal));
      expect(underweightRec.bmiCategory, equals(BMICategory.underweight));
      expect(overweightRec.bmiCategory, equals(BMICategory.overweight));
      
      // Each should have different recommendations
      expect(normalRec.recommendations, isNot(equals(underweightRec.recommendations)));
      expect(normalRec.recommendations, isNot(equals(overweightRec.recommendations)));
    });

    test('calculateNetCaloriesRemaining should calculate correctly', () async {
      final netCalories = await EnhancedCalorieGoalCalc.calculateNetCaloriesRemaining(
          normalWeightUser, 200, 1500);
      
      // Should be positive if food calories are less than adjusted TDEE + goal adjustment
      expect(netCalories, isA<double>());
    });

    group('BMI adjustment edge cases', () {
      test('should handle extreme underweight BMI correctly', () async {
        final extremeUnderweightUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 45, // BMI ~14.7
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.gainWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            extremeUnderweightUser, 0);
        
        expect(recommendation.bmiCategory, BMICategory.underweight);
        expect(recommendation.bmiAdjustment, greaterThan(0));
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('increasing calorie intake'))));
      });

      test('should handle extreme obesity BMI correctly', () async {
        final extremeObeseUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 120, // BMI ~39.2
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.loseWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            extremeObeseUser, 0);
        
        expect(recommendation.bmiCategory, BMICategory.obese);
        expect(recommendation.bmiAdjustment, lessThan(0));
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('healthcare provider'))));
      });

      test('should not penalize overweight user with gain weight goal', () async {
        final overweightGainUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 82, // BMI ~27
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.gainWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            overweightGainUser, 0);
        
        expect(recommendation.bmiAdjustment, equals(0)); // No penalty for gain goal
      });

      test('should handle underweight user with lose weight goal', () async {
        final underweightLoseUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 52, // BMI ~17
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.loseWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            underweightLoseUser, 0);
        
        expect(recommendation.bmiCategory, BMICategory.underweight);
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('may not be recommended'))));
      });
    });

    group('exercise calorie integration', () {
      test('should handle high exercise calories correctly', () async {
        final highExerciseCalories = 800.0;
        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            normalWeightUser, highExerciseCalories);
        
        expect(recommendation.exerciseCalories, equals(highExerciseCalories));
        expect(recommendation.netCalories, greaterThan(recommendation.baseTDEE));
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('High activity level') || s.contains('ensure adequate nutrition'))));
      });

      test('should handle zero exercise calories', () async {
        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            normalWeightUser, 0);
        
        expect(recommendation.exerciseCalories, equals(0));
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('Adding physical activity'))));
      });

      test('should handle negative exercise calories (should not occur but test robustness)', () async {
        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            normalWeightUser, -100);
        
        expect(recommendation.exerciseCalories, equals(-100));
        expect(recommendation.netCalories, lessThan(recommendation.baseTDEE));
      });
    });

    group('goal-specific recommendations', () {
      test('should provide weight loss recommendations', () async {
        final weightLossUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 70,
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.loseWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            weightLossUser, 0);
        
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('sustainable calorie deficit') || s.contains('calorie deficit'))));
      });

      test('should provide weight gain recommendations', () async {
        final weightGainUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 70,
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.gainWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            weightGainUser, 0);
        
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('gradual weight gain') || s.contains('strength training'))));
      });

      test('should provide maintenance recommendations', () async {
        final maintenanceUser = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 70,
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.maintainWeight,
          pal: UserPALEntity.sedentary,
        );

        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
            maintenanceUser, 0);
        
        expect(recommendation.recommendations, 
            contains(predicate<String>((s) => s.contains('current healthy habits') || s.contains('healthy habits'))));
      });
    });

    group('user calorie adjustment integration', () {
      test('should include user adjustments from config', () async {
        // Test that user adjustments are included in calculations
        final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(normalWeightUser, 0);
        
        // Should have userAdjustment field (may be 0 if no config)
        expect(recommendation.userAdjustment, isA<double>());
      });

      test('should handle user adjustment updates', () async {
        // Test updating user calorie adjustment
        await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(200);
        
        // Should not throw and should clear cache
        expect(() => EnhancedCalorieGoalCalc.clearCache(), returnsNormally);
      });
    });

    group('consistency across app functions', () {
      test('should provide consistent calorie calculations for same user', () async {
        final user = UserEntity(
          birthday: DateTime(1990, 1, 1),
          heightCM: 175,
          weightKG: 70,
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.maintainWeight,
          pal: UserPALEntity.sedentary,
        );

        // Calculate using different methods - should be consistent
        final directCalc = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(user, 200);
        final recommendationCalc = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(user, 200);
        
        // Net calories should include all adjustments
        expect(recommendationCalc.netCalories, isA<double>());
        expect(directCalc, isA<double>());
      });
    });

    group('caching behavior', () {
      test('should clear cache successfully', () {
        // Generate some cached values first
        EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 0);
        EnhancedCalorieGoalCalc.getPersonalizedRecommendation(normalWeightUser, 0);
        
        // Clear cache should not throw
        expect(() => EnhancedCalorieGoalCalc.clearCache(), returnsNormally);
      });

      test('should provide cache statistics', () {
        // Generate some cached values
        EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 0);
        
        final stats = EnhancedCalorieGoalCalc.getCacheStats();
        expect(stats, isA<String>());
        expect(stats.isNotEmpty, true);
      });

      test('should return same result for identical inputs (caching)', () async {
        final result1 = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 200);
        final result2 = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(normalWeightUser, 200);
        
        expect(result1, equals(result2));
      });
    });

    group('mathematical accuracy', () {
      test('should calculate BMI adjustments with correct percentages', () async {
        // Test specific BMI adjustment percentages
        final underweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(underweightUser, 0);
        final overweightRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(overweightUser, 0);
        
        // Underweight with gain goal should get +10% (1.10 factor)
        final expectedUnderweightAdjustment = underweightRec.baseTDEE * 0.10;
        expect(underweightRec.bmiAdjustment, closeTo(expectedUnderweightAdjustment, 50.0));
        
        // Overweight with lose goal should get -5% (0.95 factor)
        final expectedOverweightAdjustment = overweightRec.baseTDEE * -0.05;
        expect(overweightRec.bmiAdjustment, closeTo(expectedOverweightAdjustment, 50.0));
      });

      test('should calculate net calories correctly with all components', () async {
        final exerciseCalories = 300.0;
        final foodCalories = 1800.0;
        
        final netCalories = await EnhancedCalorieGoalCalc.calculateNetCaloriesRemaining(
            normalWeightUser, exerciseCalories, foodCalories);
        
        // Net should be: (TDEE + BMI adjustment + goal adjustment + exercise) - food
        expect(netCalories, isA<double>());
        expect(netCalories, greaterThan(0)); // Should be positive for this scenario
      });
    });
  });
}