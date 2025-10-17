import 'dart:math';

class WeightValidationService {
  /// Validates weight input based on unit and realistic ranges
  static WeightValidationResult validateWeight(
    double weight, {
    required bool isKilograms,
    double? previousWeight,
    int? daysSincePrevious,
  }) {
    // Convert to kg for validation if needed
    final weightInKg = isKilograms ? weight : convertLbsToKg(weight);
    
    // Basic range validation
    if (!_isInValidRange(weightInKg)) {
      return WeightValidationResult(
        isValid: false,
        severity: ValidationSeverity.error,
        message: _getRangeErrorMessage(isKilograms),
      );
    }

    // Check for unrealistic changes if previous weight is available
    if (previousWeight != null && daysSincePrevious != null && daysSincePrevious > 0) {
      final changeValidation = _validateWeightChange(
        weightInKg,
        previousWeight,
        daysSincePrevious,
      );
      
      // Return the change validation result (whether valid or invalid)
      return changeValidation;
    }

    return const WeightValidationResult(
      isValid: true,
      severity: ValidationSeverity.none,
      message: null,
    );
  }

  /// Converts pounds to kilograms
  static double convertLbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  /// Converts kilograms to pounds
  static double convertKgToLbs(double kg) {
    return kg * 2.20462;
  }

  /// Formats weight for display
  static String formatWeight(double weightKg, {required bool showInLbs}) {
    if (showInLbs) {
      final lbs = convertKgToLbs(weightKg);
      return '${lbs.toStringAsFixed(1)} lbs';
    } else {
      return '${weightKg.toStringAsFixed(1)} kg';
    }
  }

  /// Gets weight unit suffix
  static String getWeightUnit(bool isKilograms) {
    return isKilograms ? 'kg' : 'lbs';
  }

  /// Validates if weight is in realistic range (20-300 kg)
  static bool _isInValidRange(double weightKg) {
    return weightKg >= 20.0 && weightKg <= 300.0;
  }

  /// Gets appropriate error message for range validation
  static String _getRangeErrorMessage(bool isKilograms) {
    if (isKilograms) {
      return 'Weight must be between 20 and 300 kg';
    } else {
      return 'Weight must be between 44 and 661 lbs';
    }
  }

  /// Validates weight change between entries
  static WeightValidationResult _validateWeightChange(
    double currentWeightKg,
    double previousWeightKg,
    int daysSincePrevious,
  ) {
    final change = (currentWeightKg - previousWeightKg).abs();
    final changePerDay = change / daysSincePrevious;

    // More than 2kg per day is unrealistic
    if (changePerDay > 2.0) {
      return WeightValidationResult(
        isValid: false,
        severity: ValidationSeverity.warning,
        message: 'This seems like a large change (${change.toStringAsFixed(1)} kg in $daysSincePrevious days). Please double-check.',
      );
    }

    // More than 1kg per day is suspicious
    if (changePerDay > 1.0) {
      return WeightValidationResult(
        isValid: true,
        severity: ValidationSeverity.info,
        message: 'Significant weight change detected. Make sure this is accurate.',
      );
    }

    return const WeightValidationResult(
      isValid: true,
      severity: ValidationSeverity.none,
      message: null,
    );
  }

  /// Suggests appropriate decimal places for weight input
  static int getDecimalPlaces(bool isKilograms) {
    return isKilograms ? 1 : 1; // Both use 1 decimal place
  }

  /// Gets step size for weight input
  static double getStepSize(bool isKilograms) {
    return isKilograms ? 0.1 : 0.1;
  }

  /// Validates weight input string
  static bool isValidWeightString(String input) {
    if (input.isEmpty) return false;
    
    final weight = double.tryParse(input);
    return weight != null && weight > 0;
  }

  /// Rounds weight to appropriate precision
  static double roundWeight(double weight, bool isKilograms) {
    final precision = getDecimalPlaces(isKilograms);
    final factor = pow(10, precision);
    return (weight * factor).round() / factor;
  }
}

class WeightValidationResult {
  final bool isValid;
  final ValidationSeverity severity;
  final String? message;

  const WeightValidationResult({
    required this.isValid,
    required this.severity,
    this.message,
  });
}

enum ValidationSeverity {
  none,
  info,
  warning,
  error,
}