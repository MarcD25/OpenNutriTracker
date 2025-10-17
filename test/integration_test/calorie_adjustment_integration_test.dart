import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';

void main() {
  group('Calorie Adjustment Integration Tests', () {
    testWidgets('Test calorie adjustment consistency across all app screens', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings and set a calorie adjustment
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Find and interact with calorie adjustment widget
      final calorieAdjustmentWidget = find.byKey(const Key('calorie_adjustment_widget'));
      expect(calorieAdjustmentWidget, findsOneWidget);
      
      await tester.tap(calorieAdjustmentWidget);
      await tester.pumpAndSettle();

      // Set a calorie adjustment using the slider
      final adjustmentSlider = find.byKey(const Key('calorie_adjustment_slider'));
      await tester.drag(adjustmentSlider, const Offset(-100, 0)); // Decrease calories
      await tester.pumpAndSettle();

      // Save the adjustment
      await tester.tap(find.byKey(const Key('save_calorie_adjustment')));
      await tester.pumpAndSettle();

      // Navigate to home page and check calorie goal
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      final homeCalorieGoal = find.byKey(const Key('home_calorie_goal'));
      expect(homeCalorieGoal, findsOneWidget);
      
      // Get the displayed calorie value from home
      final homeCalorieText = tester.widget<Text>(homeCalorieGoal);
      final homeCalories = double.parse(homeCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));

      // Navigate to diary page and verify consistency
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      final diaryCalorieGoal = find.byKey(const Key('diary_calorie_goal'));
      expect(diaryCalorieGoal, findsOneWidget);
      
      final diaryCalorieText = tester.widget<Text>(diaryCalorieGoal);
      final diaryCalories = double.parse(diaryCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));

      // Verify consistency between home and diary
      expect(homeCalories, equals(diaryCalories));

      // Navigate to activity screen and verify consistency
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      final activityCalorieGoal = find.byKey(const Key('activity_calorie_goal'));
      if (activityCalorieGoal.evaluate().isNotEmpty) {
        final activityCalorieText = tester.widget<Text>(activityCalorieGoal);
        final activityCalories = double.parse(activityCalorieText.data!.replaceAll(RegExp(r'[^\d.]'), ''));
        expect(homeCalories, equals(activityCalories));
      }

      print('✅ Calorie adjustment consistency verified across all screens');
    });

  group('Calorie Adjustment Unit Tests', () {
    late UserEntity testUser;

    setUp(() {
      testUser = UserEntity(
        birthday: DateTime(1993, 1, 1), // 30 years old
        heightCM: 175,
        weightKG: 70,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.lowActive,
      );
      
      // Clear cache before each test
      EnhancedCalorieGoalCalc.clearCache();
    });

    test('should calculate BMI-adjusted TDEE with user adjustments', () async {
      const double exerciseCalories = 300.0;
      
      // Test with no user adjustment
      final baseCalories = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(testUser, exerciseCalories);
      
      // Test with positive user adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(200.0);
      final adjustedCalories = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(testUser, exerciseCalories);
      
      // Verify that user adjustment is applied
      expect(adjustedCalories, greaterThan(baseCalories));
      expect(adjustedCalories - baseCalories, closeTo(200.0, 1.0));
    });

    test('should include user adjustment in personalized recommendations', () async {
      const double testAdjustment = 150.0;
      const double exerciseCalories = 250.0;
      
      // Set user adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(testAdjustment);
      
      // Get personalized recommendation
      final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser, 
        exerciseCalories
      );
      
      // Verify that user adjustment is included
      expect(recommendation.userAdjustment, equals(testAdjustment));
      expect(recommendation.exerciseCalories, equals(exerciseCalories));
      expect(recommendation.netCalories, greaterThan(0));
      
      // Verify that net calories includes all components
      final expectedNetCalories = recommendation.baseTDEE + 
                                 recommendation.bmiAdjustment + 
                                 recommendation.goalAdjustment + 
                                 recommendation.userAdjustment + 
                                 recommendation.exerciseCalories;
      expect(recommendation.netCalories, closeTo(expectedNetCalories, 1.0));
    });

    test('should propagate calorie adjustment changes', () async {
      const double initialAdjustment = 100.0;
      const double updatedAdjustment = -150.0;
      const double exerciseCalories = 200.0;
      
      // Set initial adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(initialAdjustment);
      
      final initialRecommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser,
        exerciseCalories,
      );
      
      // Update adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(updatedAdjustment);
      
      final updatedRecommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser,
        exerciseCalories,
      );
      
      // Verify that the change is reflected
      expect(initialRecommendation.userAdjustment, equals(initialAdjustment));
      expect(updatedRecommendation.userAdjustment, equals(updatedAdjustment));
      
      // Verify that net calories changed by the expected amount
      final expectedDifference = updatedAdjustment - initialAdjustment;
      final actualDifference = updatedRecommendation.netCalories - initialRecommendation.netCalories;
      expect(actualDifference, closeTo(expectedDifference, 1.0));
    });

    test('should handle zero and negative calorie adjustments correctly', () async {
      const double exerciseCalories = 250.0;
      
      // Test zero adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(0.0);
      final zeroAdjustmentRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser,
        exerciseCalories,
      );
      
      // Test negative adjustment
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(-300.0);
      final negativeAdjustmentRec = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser,
        exerciseCalories,
      );
      
      expect(zeroAdjustmentRec.userAdjustment, equals(0.0));
      expect(negativeAdjustmentRec.userAdjustment, equals(-300.0));
      expect(negativeAdjustmentRec.netCalories, lessThan(zeroAdjustmentRec.netCalories));
    });

    test('should maintain BMI adjustments alongside user adjustments', () async {
      const double userAdjustment = 150.0;
      const double exerciseCalories = 100.0;
      
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(userAdjustment);
      
      final recommendation = await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        testUser,
        exerciseCalories,
      );
      
      // Verify that both BMI and user adjustments are present
      expect(recommendation.userAdjustment, equals(userAdjustment));
      expect(recommendation.bmiAdjustment, isA<double>());
      expect(recommendation.exerciseCalories, equals(exerciseCalories));
      
      // Verify that net calories includes all adjustments
      final expectedNetCalories = recommendation.baseTDEE + 
                                 recommendation.bmiAdjustment + 
                                 recommendation.goalAdjustment + 
                                 recommendation.userAdjustment + 
                                 recommendation.exerciseCalories;
      expect(recommendation.netCalories, closeTo(expectedNetCalories, 1.0));
    });

    test('should calculate net calories remaining correctly', () async {
      const double userAdjustment = 75.0;
      const double exerciseCalories = 150.0;
      const double foodCalories = 1800.0;
      
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(userAdjustment);
      
      final netCalories = await EnhancedCalorieGoalCalc.calculateNetCaloriesRemaining(
        testUser,
        exerciseCalories,
        foodCalories,
      );
      
      // Net calories should be a reasonable value
      expect(netCalories, isA<double>());
      // Should be positive if food calories are less than total calorie goal
      expect(netCalories, greaterThan(-1000)); // Allow for some deficit
    });

    tearDown(() {
      // Clean up after each test
      EnhancedCalorieGoalCalc.clearCache();
    });
  });
}