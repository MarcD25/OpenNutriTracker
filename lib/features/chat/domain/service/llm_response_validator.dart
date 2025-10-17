import 'dart:convert';
import '../entity/validation_result_entity.dart';
import '../../../../core/domain/exception/app_exception.dart';
import '../exception/validation_exception.dart';

class LLMResponseValidator {
  // Configuration constants
  static const int maxResponseLength = 10000; // 10KB max response
  static const int minResponseLength = 10; // Minimum meaningful response
  static const int maxCaloriesPerServing = 2000; // Unrealistic if higher
  static const int minCaloriesPerServing = 0; // Allow zero calories for water, diet drinks, etc.
  static const List<String> requiredNutritionKeywords = [
    'calorie', 'kcal', 'protein', 'carb', 'fat'
  ];

  /// Main validation method that checks response for all validation criteria
  ValidationResult validateResponse(String response) {
    final List<ValidationIssue> issues = [];
    ValidationSeverity maxSeverity = ValidationSeverity.info;
    String? correctedResponse;

    // Check response size
    if (!isResponseSizeReasonable(response)) {
      if (response.length > maxResponseLength) {
        issues.add(ValidationIssue.responseTooLarge);
        maxSeverity = _updateMaxSeverity(maxSeverity, ValidationSeverity.warning);
        correctedResponse = truncateIfNeeded(response);
      } else if (response.length < minResponseLength) {
        issues.add(ValidationIssue.incompleteResponse);
        maxSeverity = _updateMaxSeverity(maxSeverity, ValidationSeverity.error);
      }
    }

    // Check for nutrition information if response seems nutrition-related
    if (_isNutritionRelatedResponse(response)) {
      if (!containsRequiredNutritionInfo(response)) {
        issues.add(ValidationIssue.missingNutritionInfo);
        maxSeverity = _updateMaxSeverity(maxSeverity, ValidationSeverity.warning);
      }

      // Extract and validate calorie values
      final nutritionData = _extractNutritionData(response);
      if (nutritionData.isNotEmpty && !areCalorieValuesRealistic(nutritionData)) {
        issues.add(ValidationIssue.unrealisticCalories);
        maxSeverity = _updateMaxSeverity(maxSeverity, ValidationSeverity.error);
      }
    }

    // Check for basic formatting issues
    if (_hasFormatErrors(response)) {
      issues.add(ValidationIssue.formatError);
      maxSeverity = _updateMaxSeverity(maxSeverity, ValidationSeverity.info);
    }

    final bool isValid = maxSeverity != ValidationSeverity.critical && 
                        maxSeverity != ValidationSeverity.error;

    return ValidationResult(
      isValid: isValid,
      issues: issues,
      correctedResponse: correctedResponse,
      severity: maxSeverity,
    );
  }

  /// Checks if response size is within reasonable limits
  bool isResponseSizeReasonable(String response) {
    return response.length >= minResponseLength && 
           response.length <= maxResponseLength;
  }

  /// Checks if response contains required nutrition information
  bool containsRequiredNutritionInfo(String response) {
    if (!_isNutritionRelatedResponse(response)) {
      return true; // Not nutrition-related, so no requirement
    }

    final responseLower = response.toLowerCase();
    int foundKeywords = 0;
    
    for (final keyword in requiredNutritionKeywords) {
      if (responseLower.contains(keyword)) {
        foundKeywords++;
      }
    }

    // Require at least 3 out of 5 nutrition keywords for nutrition responses
    return foundKeywords >= 3;
  }

  /// Validates that calorie values are within realistic ranges
  bool areCalorieValuesRealistic(Map<String, dynamic> nutritionData) {
    for (final entry in nutritionData.entries) {
      if (_isCalorieField(entry.key)) {
        final value = _parseNumericValue(entry.value);
        if (value != null) {
          if (value < minCaloriesPerServing || value > maxCaloriesPerServing) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Truncates response if it exceeds maximum length
  String truncateIfNeeded(String response) {
    if (response.length <= maxResponseLength) {
      return response;
    }

    // Try to truncate at a sentence boundary
    final truncated = response.substring(0, maxResponseLength);
    final lastSentenceEnd = truncated.lastIndexOf('.');
    
    if (lastSentenceEnd > maxResponseLength * 0.8) {
      return truncated.substring(0, lastSentenceEnd + 1) + 
             '\n\n[Response truncated for length]';
    }
    
    return truncated + '...\n\n[Response truncated for length]';
  }

  /// Helper method to determine if response is nutrition-related
  bool _isNutritionRelatedResponse(String response) {
    final responseLower = response.toLowerCase();
    final nutritionIndicators = [
      'nutrition', 'calorie', 'kcal', 'protein', 'carbohydrate', 'fat',
      'vitamin', 'mineral', 'diet', 'food', 'meal', 'recipe', 'ingredient'
    ];

    return nutritionIndicators.any((indicator) => 
        responseLower.contains(indicator));
  }

  /// Extracts nutrition data from response text
  Map<String, dynamic> _extractNutritionData(String response) {
    final Map<String, dynamic> nutritionData = {};
    final lines = response.split('\n');

    for (final line in lines) {
      final lineLower = line.toLowerCase();
      
      // Look for calorie patterns like "Calories: 250" or "250 kcal" or "-50 calories"
      final calorieRegex = RegExp(r'(-?\d+)\s*(calorie|kcal|cal)s?', 
                                  caseSensitive: false);
      final calorieMatch = calorieRegex.firstMatch(line);
      if (calorieMatch != null) {
        nutritionData['calories'] = calorieMatch.group(1);
      }

      // Look for other nutrition patterns (allow negative values for validation)
      final nutritionRegex = RegExp(r'(protein|carb|fat|fiber)s?:?\s*(-?\d+)', 
                                   caseSensitive: false);
      final nutritionMatch = nutritionRegex.firstMatch(line);
      if (nutritionMatch != null) {
        nutritionData[nutritionMatch.group(1)!.toLowerCase()] = 
            nutritionMatch.group(2);
      }
    }

    return nutritionData;
  }

  /// Checks if a field name represents calories
  bool _isCalorieField(String fieldName) {
    final fieldLower = fieldName.toLowerCase();
    return fieldLower.contains('calorie') || 
           fieldLower.contains('kcal') || 
           fieldLower.contains('cal');
  }

  /// Parses numeric value from various formats
  double? _parseNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      // Remove non-numeric characters except decimal point
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  /// Checks for basic formatting errors
  bool _hasFormatErrors(String response) {
    // Check for excessive repetition
    if (_hasExcessiveRepetition(response)) {
      return true;
    }

    // Check for malformed JSON if response looks like JSON
    if (response.trim().startsWith('{') || response.trim().startsWith('[')) {
      try {
        json.decode(response);
      } catch (e) {
        return true;
      }
    }

    return false;
  }

  /// Checks for excessive character or word repetition
  bool _hasExcessiveRepetition(String response) {
    // Check for repeated characters (more than 5 in a row)
    if (RegExp(r'(.)\1{5,}').hasMatch(response)) {
      return true;
    }

    // Check for repeated words
    final words = response.toLowerCase().split(RegExp(r'\s+'));
    if (words.length > 10) {
      final wordCounts = <String, int>{};
      for (final word in words) {
        if (word.length > 3) { // Only count meaningful words
          wordCounts[word] = (wordCounts[word] ?? 0) + 1;
        }
      }
      
      // If any word appears more than 20% of the time, it's excessive
      final maxCount = wordCounts.values.fold(0, (max, count) => 
          count > max ? count : max);
      if (maxCount > words.length * 0.2) {
        return true;
      }
    }

    return false;
  }

  /// Updates maximum severity level
  ValidationSeverity _updateMaxSeverity(ValidationSeverity current, 
                                       ValidationSeverity new_) {
    final severityOrder = [
      ValidationSeverity.info,
      ValidationSeverity.warning,
      ValidationSeverity.error,
      ValidationSeverity.critical,
    ];

    final currentIndex = severityOrder.indexOf(current);
    final newIndex = severityOrder.indexOf(new_);

    return newIndex > currentIndex ? new_ : current;
  }
}