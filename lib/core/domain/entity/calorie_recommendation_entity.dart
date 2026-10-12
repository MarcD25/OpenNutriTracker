/// Entity representing a personalized calorie recommendation with detailed breakdown
/// and BMI-specific adjustments for enhanced nutrition guidance.
class CalorieRecommendation {
  /// Base Total Daily Energy Expenditure without adjustments
  final double baseTDEE;
  
  /// Calories burned through exercise (positive value)
  final double exerciseCalories;
  
  /// BMI-based adjustment to calories (can be positive or negative)
  final double bmiAdjustment;
  
  /// Goal-based adjustment (e.g., -500 for weight loss, +500 for weight gain)
  final double goalAdjustment;
  
  /// User-defined calorie adjustment from settings
  final double userAdjustment;
  
  /// Final net calorie target after all adjustments
  final double netCalories;
  
  /// User's BMI category for context
  final BMICategory bmiCategory;
  
  /// Personalized recommendations based on user profile
  final List<String> recommendations;

  const CalorieRecommendation({
    required this.baseTDEE,
    required this.exerciseCalories,
    required this.bmiAdjustment,
    required this.goalAdjustment,
    required this.userAdjustment,
    required this.netCalories,
    required this.bmiCategory,
    required this.recommendations,
  });

  /// Total calorie target including exercise but before goal and user adjustments
  double get adjustedTDEE => baseTDEE + bmiAdjustment + exerciseCalories;
  
  /// Whether the BMI adjustment is increasing calories
  bool get hasBMIBonus => bmiAdjustment > 0;
  
  /// Whether the BMI adjustment is decreasing calories
  bool get hasBMIPenalty => bmiAdjustment < 0;
  
  /// Percentage change from base TDEE due to BMI adjustment
  double get bmiAdjustmentPercentage => (bmiAdjustment / baseTDEE) * 100;
  
  /// Whether exercise calories are included in the calculation
  bool get hasExerciseCalories => exerciseCalories > 0;
  
  /// Summary of all adjustments for display purposes
  Map<String, double> get adjustmentBreakdown => {
    'Base TDEE': baseTDEE,
    'BMI Adjustment': bmiAdjustment,
    'Exercise Calories': exerciseCalories,
    'Goal Adjustment': goalAdjustment,
    'User Adjustment': userAdjustment,
    'Net Target': netCalories,
  };

  @override
  String toString() {
    return 'CalorieRecommendation(baseTDEE: $baseTDEE, exerciseCalories: $exerciseCalories, '
           'bmiAdjustment: $bmiAdjustment, goalAdjustment: $goalAdjustment, '
           'userAdjustment: $userAdjustment, netCalories: $netCalories, bmiCategory: $bmiCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalorieRecommendation &&
        other.baseTDEE == baseTDEE &&
        other.exerciseCalories == exerciseCalories &&
        other.bmiAdjustment == bmiAdjustment &&
        other.goalAdjustment == goalAdjustment &&
        other.userAdjustment == userAdjustment &&
        other.netCalories == netCalories &&
        other.bmiCategory == bmiCategory;
  }

  @override
  int get hashCode {
    return baseTDEE.hashCode ^
        exerciseCalories.hashCode ^
        bmiAdjustment.hashCode ^
        goalAdjustment.hashCode ^
        userAdjustment.hashCode ^
        netCalories.hashCode ^
        bmiCategory.hashCode;
  }
}

/// BMI categories for calorie recommendation context
enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}

/// Extension to provide human-readable BMI category descriptions
extension BMICategoryExtension on BMICategory {
  String get displayName {
    switch (this) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal Weight';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }
  
  String get description {
    switch (this) {
      case BMICategory.underweight:
        return 'BMI below 18.5 - Consider healthy weight gain';
      case BMICategory.normal:
        return 'BMI 18.5-24.9 - Healthy weight range';
      case BMICategory.overweight:
        return 'BMI 25.0-29.9 - Above healthy weight range';
      case BMICategory.obese:
        return 'BMI 30.0+ - Significantly above healthy weight range';
    }
  }
}