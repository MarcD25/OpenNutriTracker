import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';

class CalorieValidationService {
  static const double _minReasonableCaloriesPerMinute = 1.0;
  static const double _maxReasonableCaloriesPerMinute = 25.0;
  static const double _extremeCaloriesPerMinute = 35.0;

  static CalorieValidationResult validateCalories({
    required double calories,
    required double durationMinutes,
    required UserEntity user,
    required PhysicalActivityEntity activity,
  }) {
    if (durationMinutes <= 0) {
      return CalorieValidationResult(
        isValid: false,
        severity: ValidationSeverity.error,
        message: 'Duration must be greater than 0',
      );
    }

    final caloriesPerMinute = calories / durationMinutes;
    
    // Check for unrealistically low values
    if (caloriesPerMinute < _minReasonableCaloriesPerMinute) {
      return CalorieValidationResult(
        isValid: false,
        severity: ValidationSeverity.warning,
        message: 'Calories seem low for this activity. Consider checking your input.',
      );
    }
    
    // Check for unrealistically high values
    if (caloriesPerMinute > _extremeCaloriesPerMinute) {
      return CalorieValidationResult(
        isValid: false,
        severity: ValidationSeverity.error,
        message: 'Calories seem extremely high. Please verify your input.',
      );
    }
    
    // Check for high but possibly valid values
    if (caloriesPerMinute > _maxReasonableCaloriesPerMinute) {
      return CalorieValidationResult(
        isValid: true,
        severity: ValidationSeverity.warning,
        message: 'High calorie burn detected. Please verify this is accurate.',
      );
    }

    return CalorieValidationResult(
      isValid: true,
      severity: ValidationSeverity.none,
      message: null,
    );
  }

  static double calculateRecommendedCalories({
    required UserEntity user,
    required PhysicalActivityEntity activity,
    required double durationMinutes,
    required double intensityMultiplier,
  }) {
    // Base MET calculation with intensity adjustment
    final baseMET = activity.mets * intensityMultiplier;
    return baseMET * user.weightKG * durationMinutes / 60;
  }
}

class CalorieValidationResult {
  final bool isValid;
  final ValidationSeverity severity;
  final String? message;

  CalorieValidationResult({
    required this.isValid,
    required this.severity,
    this.message,
  });
}

enum ValidationSeverity {
  none,
  warning,
  error,
}