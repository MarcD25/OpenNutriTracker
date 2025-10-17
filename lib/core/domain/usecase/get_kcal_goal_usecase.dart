import 'package:collection/collection.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/data/repository/user_activity_repository.dart';
import 'package:opennutritracker/core/data/repository/user_repository.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/calorie_recommendation_entity.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';

class GetKcalGoalUsecase {
  final UserRepository _userRepository;
  final ConfigRepository _configRepository;
  final UserActivityRepository _userActivityRepository;

  GetKcalGoalUsecase(
      this._userRepository, this._configRepository, this._userActivityRepository);

  /// Legacy method for backward compatibility
  /// Uses the original calorie calculation without BMI adjustments
  Future<double> getKcalGoal(
      {UserEntity? userEntity,
      double? totalKcalActivitiesParam,
      double? kcalUserAdjustment}) async {
    final user = userEntity ?? await _userRepository.getUserData();
    final config = await _configRepository.getConfig();
    final totalKcalActivities = totalKcalActivitiesParam ??
        (await _userActivityRepository.getAllUserActivityByDate(DateTime.now()))
            .map((activity) => activity.burnedKcal)
            .toList()
            .sum;
    return CalorieGoalCalc.getTotalKcalGoal(user, totalKcalActivities,
        kcalUserAdjustment: config.userKcalAdjustment);
  }

  /// Enhanced method that uses BMI-specific calorie calculations
  /// This method incorporates BMI adjustments and provides more personalized recommendations
  Future<double> getEnhancedKcalGoal(
      {UserEntity? userEntity,
      double? totalKcalActivitiesParam,
      double? kcalUserAdjustment}) async {
    final user = userEntity ?? await _userRepository.getUserData();
    final totalKcalActivities = totalKcalActivitiesParam ??
        (await _userActivityRepository.getAllUserActivityByDate(DateTime.now()))
            .map((activity) => activity.burnedKcal)
            .toList()
            .sum;
    
    // Calculate BMI-adjusted TDEE with exercise and user adjustments
    final bmiAdjustedTDEE = await EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(
        user, totalKcalActivities);
    
    // Add goal adjustment (user adjustment is already included in bmiAdjustedTDEE)
    final goalAdjustment = CalorieGoalCalc.getKcalGoalAdjustment(user.goal);
    
    return bmiAdjustedTDEE + goalAdjustment;
  }

  /// Gets a comprehensive calorie recommendation with detailed breakdown
  /// This method provides the most detailed information for advanced users
  Future<CalorieRecommendation> getCalorieRecommendation(
      {UserEntity? userEntity,
      double? totalKcalActivitiesParam}) async {
    final user = userEntity ?? await _userRepository.getUserData();
    final totalKcalActivities = totalKcalActivitiesParam ??
        (await _userActivityRepository.getAllUserActivityByDate(DateTime.now()))
            .map((activity) => activity.burnedKcal)
            .toList()
            .sum;
    
    return await EnhancedCalorieGoalCalc.getPersonalizedRecommendation(
        user, totalKcalActivities);
  }

  /// Calculates net calories remaining after food intake
  /// Useful for real-time calorie tracking throughout the day
  Future<double> getNetCaloriesRemaining(
      {required double foodCaloriesConsumed,
      UserEntity? userEntity,
      double? totalKcalActivitiesParam}) async {
    final user = userEntity ?? await _userRepository.getUserData();
    final totalKcalActivities = totalKcalActivitiesParam ??
        (await _userActivityRepository.getAllUserActivityByDate(DateTime.now()))
            .map((activity) => activity.burnedKcal)
            .toList()
            .sum;
    
    return await EnhancedCalorieGoalCalc.calculateNetCaloriesRemaining(
        user, totalKcalActivities, foodCaloriesConsumed);
  }
}
