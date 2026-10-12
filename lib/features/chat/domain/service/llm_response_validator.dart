import 'dart:convert';
import '../entity/validation_result_entity.dart';
import '../../../../core/domain/exception/app_exception.dart';

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


    // Check for basic formatting issues
    final hasFormattingErrors = _hasFormatErrors(response);
    if (hasFormattingErrors) {
      issues.add(ValidationIssue.formatError);
      // Format error severity remains info
    }

    // Check for nutrition information if response seems nutrition-related
    if (_isNutritionRelatedResponse(response)) {
      if (!hasFormattingErrors && !containsRequiredNutritionInfo(response)) {
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

    final bool isValid = maxSeverity != ValidationSeverity.critical && 
                        maxSeverity != ValidationSeverity.error;

    return ValidationResult(
      isValid: isValid,
      issues: issues,
      correctedResponse: correctedResponse,
      severity: issues.isEmpty ? ValidationSeverity.info : maxSeverity,
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

    // If response already contains explicit nutrition line items or recipes, it's valid
    final responseLower = response.toLowerCase();
    if (responseLower.contains('recipe') || 
        responseLower.contains('serving') || 
        responseLower.contains('approximately:')) {
      return true;
    }

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
    final weightGrams = _parseNumericValue(nutritionData['weight_grams']);
    final calories = _parseNumericValue(nutritionData['calories']);
    if (weightGrams != null && calories != null && weightGrams > 0) {
      // Pure fat is 9 kcal/g, so > 9 kcal/g is physically impossible for food
      if (calories / weightGrams > 9.0) {
        return false;
      }
    }

    for (final entry in nutritionData.entries) {
      if (_isCalorieField(entry.key)) {
        final value = _parseNumericValue(entry.value);
        if (value != null) {
          // Zero calories is valid; negative calories or calories > 2000 are unrealistic
          if (value < minCaloriesPerServing || value > maxCaloriesPerServing) {
            return false;
          }
          // Flag mixed/combined values where single item has > 600 from multiple formats
          if (entry.key == 'calories_combined' && value > 600) {
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
             '[Response truncated for length]';
    }
    
    return truncated + '...[Response truncated for length]';
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

    // Extract weight in grams if present
    final weightRegex = RegExp(r'(?:weight|portion|serving\s*size)s?:?\s*(\d+(?:\.\d+)?)\s*g', caseSensitive: false);
    final weightMatch = weightRegex.firstMatch(response);
    if (weightMatch != null) {
      nutritionData['weight_grams'] = weightMatch.group(1);
    }

    // Check for range patterns like "200-250 kcal" or "200 - 250 calories"
    final rangeRegex = RegExp(r'(\d+)\s*-\s*(\d+)\s*(calorie|kcal|cal)s?', caseSensitive: false);
    final rangeMatch = rangeRegex.firstMatch(response);
    if (rangeMatch != null) {
      nutritionData['calories'] = rangeMatch.group(2); // Upper bound
      return nutritionData;
    }

    // Strip out parenthesized text (like "(100 calories)" in macro breakdowns)
    final cleanForCalories = response.replaceAll(RegExp(r'\([^)]*\)'), '');
    final responseLower = response.toLowerCase();
    final isRecipeOrServing = responseLower.contains('recipe') || 
                              responseLower.contains('serves') || 
                              responseLower.contains('per serving');

    // Match all calorie patterns across the response
    final calorieRegex = RegExp(r'(-?\d+(?:\.\d+)?)\s*(calorie|kcal|cal)s?', 
                                caseSensitive: false);
    final allCalorieMatches = calorieRegex.allMatches(cleanForCalories).toList();
    if (!isRecipeOrServing && allCalorieMatches.length > 1) {
      double totalCals = 0;
      for (final m in allCalorieMatches) {
        totalCals += double.tryParse(m.group(1) ?? '0') ?? 0;
      }
      nutritionData['calories_combined'] = totalCals.toString();
      nutritionData['calories'] = allCalorieMatches.first.group(1);
    } else if (allCalorieMatches.isNotEmpty) {
      final perServingRegex = RegExp(r'per\s*serving:?\s*(\d+(?:\.\d+)?)\s*(calorie|kcal|cal)s?', caseSensitive: false);
      final perServingMatch = perServingRegex.firstMatch(cleanForCalories);
      if (perServingMatch != null) {
        nutritionData['calories'] = perServingMatch.group(1);
      } else {
        nutritionData['calories'] = allCalorieMatches.first.group(1);
      }
    }

    // Look for other nutrition patterns
    final nutritionRegex = RegExp(r'(protein|carb|fat|fiber)s?:?\s*(-?\d+(?:\.\d+)?)', 
                                 caseSensitive: false);
    for (final match in nutritionRegex.allMatches(response)) {
      nutritionData[match.group(1)!.toLowerCase()] = match.group(2);
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
      final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(0)!);
      }
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
    // Check for repeated non-whitespace characters (more than 5 in a row)
    if (RegExp(r'(\S)\1{5,}').hasMatch(response)) {
      return true;
    }

    // Check for repeated sentences or lines
    final linesOrSentences = response
        .split(RegExp(r'[.!?\n]+'))
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.length > 5)
        .toList();
    final sentenceCounts = <String, int>{};
    for (final s in linesOrSentences) {
      sentenceCounts[s] = (sentenceCounts[s] ?? 0) + 1;
      if (sentenceCounts[s]! >= 3) {
        return true;
      }
    }

    // Check for repeated non-stop words (only words with length > 4 and frequency > 4)
    final stopWords = {'this', 'that', 'with', 'from', 'food', 'meal', 'contains', 'nutrition', 'here', 'breakdown', 'nutritious'};
    final words = response.toLowerCase().split(RegExp(r'\s+'));
    if (words.length > 15) {
      final wordCounts = <String, int>{};
      for (final word in words) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
        if (cleanWord.length > 3 && !stopWords.contains(cleanWord)) {
          wordCounts[cleanWord] = (wordCounts[cleanWord] ?? 0) + 1;
        }
      }
      
      for (final count in wordCounts.values) {
        if (count >= 3 && count > words.length * 0.15) {
          return true;
        }
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