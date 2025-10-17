import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_bmi_entity.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/utils/calc/bmi_calc.dart';
import 'package:opennutritracker/core/domain/entity/calorie_recommendation_entity.dart';
import 'package:opennutritracker/core/domain/service/calculation_cache_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';

/// Enhanced calorie calculation utility that incorporates BMI-specific adjustments
/// and exercise calories for more personalized calorie recommendations.
/// Uses caching for performance optimization of frequently calculated values.
class EnhancedCalorieGoalCalc {
  static final _cache = CalculationCacheService();
  /// Calculates BMI-adjusted TDEE including exercise calories and user adjustments
  /// 
  /// This method takes the base TDEE and applies BMI-specific adjustments
  /// based on the user's current BMI category and weight goals, plus user-defined
  /// calorie adjustments from settings. Results are cached for performance optimization.
  static Future<double> calculateBMIAdjustedTDEE(UserEntity user, double exerciseCalories) async {
    final cacheKey = 'bmi_adjusted_tdee_${user.hashCode}_$exerciseCalories';
    
    return await _cache.getOrCalculate(
      cacheKey,
      () async {
        final baseTDEE = CalorieGoalCalc.getTdee(user);
        final bmi = BMICalc.getBMI(user);
        final bmiAdjustment = _getBMIAdjustmentFactor(bmi, user.goal);
        final exerciseAdjustment = exerciseCalories;
        final userAdjustment = await _getUserCalorieAdjustment();
        
        return (baseTDEE * bmiAdjustment) + exerciseAdjustment + userAdjustment;
      },
      ttl: const Duration(minutes: 30), // Cache for 30 minutes
    );
  }

  /// Synchronous version for backward compatibility - does not include user adjustments
  /// Use calculateBMIAdjustedTDEE for full functionality
  @Deprecated('Use calculateBMIAdjustedTDEE for full functionality including user adjustments')
  static double calculateBMIAdjustedTDEESync(UserEntity user, double exerciseCalories) {
    final cacheKey = 'bmi_adjusted_tdee_sync_${user.hashCode}_$exerciseCalories';
    
    return _cache.getOrCalculateSync(
      cacheKey,
      () {
        final baseTDEE = CalorieGoalCalc.getTdee(user);
        final bmi = BMICalc.getBMI(user);
        final bmiAdjustment = _getBMIAdjustmentFactor(bmi, user.goal);
        final exerciseAdjustment = exerciseCalories;
        
        return (baseTDEE * bmiAdjustment) + exerciseAdjustment;
      },
      ttl: const Duration(minutes: 30), // Cache for 30 minutes
    );
  }

  /// Gets BMI-specific adjustment factor based on BMI category and weight goal
  /// 
  /// Adjustment factors:
  /// - Underweight (BMI < 18.5): +5-10% calories for weight gain goals
  /// - Normal (18.5-24.9): Standard calculation (no adjustment)
  /// - Overweight (25-29.9): -5% for weight loss goals
  /// - Obese (BMI >= 30): -10-15% for weight loss goals
  static double _getBMIAdjustmentFactor(double bmi, UserWeightGoalEntity goal) {
    final nutritionalStatus = BMICalc.getNutritionalStatus(bmi);
    
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        // Encourage healthy weight gain
        if (goal == UserWeightGoalEntity.gainWeight) {
          return 1.10; // +10% calories
        } else if (goal == UserWeightGoalEntity.maintainWeight) {
          return 1.05; // +5% calories to reach healthy weight
        }
        return 1.0; // Standard for weight loss (though not recommended)
        
      case UserNutritionalStatus.normalWeight:
        return 1.0; // Standard calculation
        
      case UserNutritionalStatus.preObesity:
        // Slight reduction for weight loss
        if (goal == UserWeightGoalEntity.loseWeight) {
          return 0.95; // -5% calories
        }
        return 1.0; // Standard for maintain/gain
        
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
        // Moderate reduction for weight loss
        if (goal == UserWeightGoalEntity.loseWeight) {
          return 0.90; // -10% calories
        }
        return 1.0; // Standard for maintain/gain
        
      case UserNutritionalStatus.obesityClassIII:
        // More aggressive reduction for weight loss
        if (goal == UserWeightGoalEntity.loseWeight) {
          return 0.85; // -15% calories
        }
        return 1.0; // Standard for maintain/gain
    }
  }

  /// Generates personalized calorie recommendation with detailed breakdown
  /// Results are cached for performance optimization.
  static Future<CalorieRecommendation> getPersonalizedRecommendation(
      UserEntity user, double exerciseCalories) async {
    final cacheKey = 'personalized_recommendation_${user.hashCode}_$exerciseCalories';
    
    return await _cache.getOrCalculate(
      cacheKey,
      () async {
        final baseTDEE = CalorieGoalCalc.getTdee(user);
        final bmi = BMICalc.getBMI(user);
        final bmiCategory = _getBMICategory(BMICalc.getNutritionalStatus(bmi));
        final bmiAdjustmentFactor = _getBMIAdjustmentFactor(bmi, user.goal);
        final bmiAdjustment = (baseTDEE * bmiAdjustmentFactor) - baseTDEE;
        final goalAdjustment = CalorieGoalCalc.getKcalGoalAdjustment(user.goal);
        final userAdjustment = await _getUserCalorieAdjustment();
        final netCalories = baseTDEE + bmiAdjustment + goalAdjustment + userAdjustment + exerciseCalories;
        
        return CalorieRecommendation(
          baseTDEE: baseTDEE,
          exerciseCalories: exerciseCalories,
          bmiAdjustment: bmiAdjustment,
          goalAdjustment: goalAdjustment,
          userAdjustment: userAdjustment,
          netCalories: netCalories,
          bmiCategory: bmiCategory,
          recommendations: _generateRecommendations(user, bmi, exerciseCalories),
        );
      },
      ttl: const Duration(minutes: 30), // Cache for 30 minutes
    );
  }

  /// Converts UserNutritionalStatus to BMICategory for the recommendation entity
  static BMICategory _getBMICategory(UserNutritionalStatus status) {
    switch (status) {
      case UserNutritionalStatus.underWeight:
        return BMICategory.underweight;
      case UserNutritionalStatus.normalWeight:
        return BMICategory.normal;
      case UserNutritionalStatus.preObesity:
        return BMICategory.overweight;
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        return BMICategory.obese;
    }
  }

  /// Generates personalized recommendations based on user profile and BMI
  static List<String> _generateRecommendations(
      UserEntity user, double bmi, double exerciseCalories) {
    final recommendations = <String>[];
    final nutritionalStatus = BMICalc.getNutritionalStatus(bmi);
    
    // BMI-specific recommendations
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        recommendations.add('Consider increasing calorie intake with nutrient-dense foods');
        if (user.goal == UserWeightGoalEntity.loseWeight) {
          recommendations.add('Weight loss may not be recommended with your current BMI');
        }
        break;
        
      case UserNutritionalStatus.normalWeight:
        recommendations.add('Your BMI is in the healthy range');
        if (exerciseCalories > 0) {
          recommendations.add('Great job staying active! Your calories are adjusted for exercise');
        }
        break;
        
      case UserNutritionalStatus.preObesity:
        if (user.goal == UserWeightGoalEntity.loseWeight) {
          recommendations.add('A modest calorie reduction can help achieve healthy weight');
        }
        recommendations.add('Regular exercise can help improve your health profile');
        break;
        
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        if (user.goal == UserWeightGoalEntity.loseWeight) {
          recommendations.add('A structured weight loss plan may provide significant health benefits');
        }
        recommendations.add('Consider consulting with a healthcare provider for personalized guidance');
        break;
    }
    
    // Exercise-specific recommendations
    if (exerciseCalories == 0) {
      recommendations.add('Adding physical activity can improve your overall health');
    } else if (exerciseCalories > 500) {
      recommendations.add('High activity level detected - ensure adequate nutrition for recovery');
    }
    
    // Goal-specific recommendations
    switch (user.goal) {
      case UserWeightGoalEntity.loseWeight:
        recommendations.add('Focus on creating a sustainable calorie deficit');
        break;
      case UserWeightGoalEntity.gainWeight:
        recommendations.add('Aim for gradual weight gain with strength training');
        break;
      case UserWeightGoalEntity.maintainWeight:
        recommendations.add('Maintain your current healthy habits');
        break;
    }
    
    return recommendations;
  }

  /// Calculates net calories remaining after food intake
  /// Results are cached for performance optimization.
  static Future<double> calculateNetCaloriesRemaining(
      UserEntity user, double exerciseCalories, double foodCalories) async {
    final cacheKey = 'net_calories_${user.hashCode}_${exerciseCalories}_$foodCalories';
    
    return await _cache.getOrCalculate(
      cacheKey,
      () async {
        final totalCalorieGoal = await calculateBMIAdjustedTDEE(user, exerciseCalories);
        final goalAdjustment = CalorieGoalCalc.getKcalGoalAdjustment(user.goal);
        return totalCalorieGoal + goalAdjustment - foodCalories;
      },
      ttl: const Duration(minutes: 15), // Shorter cache for dynamic values
    );
  }

  /// Clears all cached calculations (useful when user data changes significantly)
  static void clearCache() {
    _cache.clear();
  }

  /// Gets cache statistics for monitoring performance
  static String getCacheStats() {
    return _cache.getStats().toString();
  }

  /// Gets user-defined calorie adjustment from settings
  /// This ensures consistency across all app functions
  static Future<double> _getUserCalorieAdjustment() async {
    try {
      final configRepository = locator<ConfigRepository>();
      final config = await configRepository.getConfig();
      return config.userKcalAdjustment ?? 0.0;
    } catch (e) {
      // Fallback to 0 if config cannot be loaded
      return 0.0;
    }
  }

  /// Updates user calorie adjustment setting and clears related cache
  /// This ensures the change propagates to all calorie calculations
  static Future<void> updateUserCalorieAdjustment(double adjustment) async {
    try {
      final configRepository = locator<ConfigRepository>();
      await configRepository.setConfigKcalAdjustment(adjustment);
      
      // Clear cache to ensure new values are used
      _cache.clearByPattern('bmi_adjusted_tdee');
      _cache.clearByPattern('personalized_recommendation');
      _cache.clearByPattern('net_calories');
    } catch (e) {
      // Log error but don't throw to avoid breaking the UI
      // TODO: Use proper logging service instead of print
    }
  }
}