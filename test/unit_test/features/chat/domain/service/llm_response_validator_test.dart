import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/features/chat/domain/service/llm_response_validator.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';

void main() {
  late LLMResponseValidator validator;

  setUp(() {
    validator = LLMResponseValidator();
  });

  group('LLMResponseValidator', () {
    group('validateResponse', () {
      test('should validate normal response as valid', () {
        // Arrange
        const response = 'This is a normal response with good nutrition information. '
            'It contains calories: 250 kcal, protein: 15g, carbs: 30g, fat: 8g.';

        // Act
        final result = validator.validateResponse(response);

        // Assert
        expect(result.isValid, true);
        expect(result.severity, ValidationSeverity.info);
        expect(result.issues, isEmpty);
      });

      test('should flag response as too large', () {
        // Arrange
        final longResponse = 'A' * 15000; // Exceeds maxResponseLength

        // Act
        final result = validator.validateResponse(longResponse);

        // Assert
        expect(result.isValid, true); // Still valid but with warning
        expect(result.severity, ValidationSeverity.warning);
        expect(result.issues, contains(ValidationIssue.responseTooLarge));
        expect(result.correctedResponse, isNotNull);
        expect(result.correctedResponse!.length, lessThan(longResponse.length));
      });

      test('should flag response as too short', () {
        // Arrange
        const shortResponse = 'Hi'; // Below minResponseLength

        // Act
        final result = validator.validateResponse(shortResponse);

        // Assert
        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
        expect(result.issues, contains(ValidationIssue.incompleteResponse));
      });

      test('should detect missing nutrition info in nutrition-related response', () {
        // Arrange
        const nutritionResponse = 'This food is healthy and good for you. '
            'It tastes great and is very nutritious.'; // Missing specific nutrition data

        // Act
        final result = validator.validateResponse(nutritionResponse);

        // Assert
        expect(result.issues, contains(ValidationIssue.missingNutritionInfo));
        expect(result.severity, ValidationSeverity.warning);
      });

      test('should detect unrealistic calorie values', () {
        // Arrange
        const unrealisticResponse = 'This apple contains 5000 calories and is very healthy.';

        // Act
        final result = validator.validateResponse(unrealisticResponse);

        // Assert
        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
        expect(result.issues, contains(ValidationIssue.unrealisticCalories));
      });

      test('should detect format errors', () {
        // Arrange
        final malformedResponse = 'This response has excessive repetition: ' +
            'a' * 50; // Excessive character repetition

        // Act
        final result = validator.validateResponse(malformedResponse);

        // Assert
        expect(result.issues, contains(ValidationIssue.formatError));
      });
    });

    group('isResponseSizeReasonable', () {
      test('should return true for normal sized response', () {
        const response = 'This is a normal response with reasonable length.';
        expect(validator.isResponseSizeReasonable(response), true);
      });

      test('should return false for too short response', () {
        const response = 'Hi';
        expect(validator.isResponseSizeReasonable(response), false);
      });

      test('should return false for too long response', () {
        final response = 'A' * 15000;
        expect(validator.isResponseSizeReasonable(response), false);
      });
    });

    group('containsRequiredNutritionInfo', () {
      test('should return true for non-nutrition response', () {
        const response = 'Hello, how can I help you today?';
        expect(validator.containsRequiredNutritionInfo(response), true);
      });

      test('should return true for nutrition response with required keywords', () {
        const response = 'This food contains 250 calories, 15g protein, 30g carbs, and 8g fat.';
        expect(validator.containsRequiredNutritionInfo(response), true);
      });

      test('should return false for nutrition response missing keywords', () {
        const response = 'This food is very nutritious and healthy for you.';
        expect(validator.containsRequiredNutritionInfo(response), false);
      });
    });

    group('areCalorieValuesRealistic', () {
      test('should return true for realistic calorie values', () {
        final nutritionData = {
          'calories': '250',
          'protein_calories': '60',
        };
        expect(validator.areCalorieValuesRealistic(nutritionData), true);
      });

      test('should return false for unrealistic high calorie values', () {
        final nutritionData = {
          'calories': '5000',
        };
        expect(validator.areCalorieValuesRealistic(nutritionData), false);
      });

      test('should return false for negative calorie values', () {
        final nutritionData = {
          'calories': '-100',
        };
        expect(validator.areCalorieValuesRealistic(nutritionData), false);
      });

      test('should return true for zero calorie values', () {
        final nutritionData = {
          'calories': '0',
        };
        expect(validator.areCalorieValuesRealistic(nutritionData), true);
      });
    });

    group('truncateIfNeeded', () {
      test('should not truncate normal length response', () {
        const response = 'This is a normal response.';
        final result = validator.truncateIfNeeded(response);
        expect(result, equals(response));
      });

      test('should truncate overly long response', () {
        final longResponse = 'A' * 15000;
        final result = validator.truncateIfNeeded(longResponse);
        
        expect(result.length, lessThan(longResponse.length));
        expect(result, contains('[Response truncated for length]'));
      });

      test('should truncate at sentence boundary when possible', () {
        final longResponse = 'This is sentence one. ' * 500 + 'This is the last sentence.';
        final result = validator.truncateIfNeeded(longResponse);
        
        expect(result, contains('[Response truncated for length]'));
        expect(result, endsWith('.[Response truncated for length]'));
      });
    });

    group('edge cases', () {
      test('should handle empty response', () {
        const response = '';
        final result = validator.validateResponse(response);
        
        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
        expect(result.issues, contains(ValidationIssue.incompleteResponse));
      });

      test('should handle response with only whitespace', () {
        const response = '   \n\t   ';
        final result = validator.validateResponse(response);
        
        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
      });

      test('should handle malformed JSON response', () {
        const response = '{"nutrition": "data", "calories": 250'; // Missing closing brace
        final result = validator.validateResponse(response);
        
        expect(result.issues, contains(ValidationIssue.formatError));
      });

      test('should handle response with mixed calorie formats', () {
        const response = 'This meal has 250 calories, 300 kcal, and 150 cal total.';
        final result = validator.validateResponse(response);
        
        // Should detect the unrealistic total (250+300+150 = 700 for one item)
        expect(result.isValid, false); // Individual values are unrealistic when combined
      });

      test('should handle response with decimal calorie values', () {
        const response = 'This snack contains 125.5 calories and is healthy.';
        final result = validator.validateResponse(response);
        
        expect(result.isValid, true);
      });

      test('should handle response with exercise calories (negative)', () {
        const response = 'Running burns -300 calories from your daily intake.';
        final result = validator.validateResponse(response);
        
        // Negative calories should be flagged as unrealistic in food context
        expect(result.isValid, false);
        expect(result.issues, contains(ValidationIssue.unrealisticCalories));
      });
    });

    group('nutrition data extraction and validation', () {
      test('should validate nutrition response with structured data', () {
        const response = '''
        Here's the nutrition information for your meal:
        - Calories: 450 kcal
        - Protein: 25g (100 calories)
        - Carbohydrates: 60g (240 calories)
        - Fat: 12g (108 calories)
        - Fiber: 8g
        - Sugar: 15g
        ''';

        final result = validator.validateResponse(response);
        expect(result.isValid, true);
        expect(validator.containsRequiredNutritionInfo(response), true);
      });

      test('should validate portion sizes against calorie content', () {
        const unrealisticResponse = '''
        One apple contains:
        - Calories: 2000 kcal
        - Weight: 150g
        ''';

        final result = validator.validateResponse(unrealisticResponse);
        expect(result.isValid, false);
        expect(result.issues, contains(ValidationIssue.unrealisticCalories));
      });
    });

    group('response quality assessment', () {
      test('should assess response completeness', () {
        const incompleteResponse = 'This food is healthy and contains vitamins.';
        const completeResponse = '''
        This food is healthy and nutritious. Here's the breakdown:
        - Calories: 250 kcal
        - Protein: 15g
        - Carbohydrates: 30g
        - Fat: 8g
        - Key vitamins: A, C, K
        - Minerals: Iron, Calcium
        ''';

        final incompleteResult = validator.validateResponse(incompleteResponse);
        final completeResult = validator.validateResponse(completeResponse);

        expect(incompleteResult.issues, contains(ValidationIssue.missingNutritionInfo));
        expect(completeResult.isValid, true);
        expect(completeResult.issues, isEmpty);
      });

      test('should detect repetitive or low-quality content', () {
        final repetitiveResponse = '''
        This food is healthy. This food is nutritious. This food is good.
        This food is healthy. This food is nutritious. This food is good.
        This food is healthy. This food is nutritious. This food is good.
        ''';

        final result = validator.validateResponse(repetitiveResponse);
        expect(result.issues, contains(ValidationIssue.formatError));
        expect(result.severity, ValidationSeverity.info);
      });
    });

    group('advanced validation scenarios', () {
      test('should handle mixed unit systems in nutrition data', () {
        const mixedUnitsResponse = '''
        Nutrition per serving:
        - Calories: 300 kcal
        - Protein: 20 grams
        - Carbs: 45g
        - Fat: 10 g
        - Sodium: 500mg
        - Potassium: 0.4g
        ''';

        final result = validator.validateResponse(mixedUnitsResponse);
        expect(result.isValid, true);
        // Should normalize units internally
      });

      test('should validate recipe vs single food item responses', () {
        const recipeResponse = '''
        Recipe nutrition (serves 4):
        Total calories: 1200 kcal
        Per serving: 300 kcal
        Ingredients: chicken, rice, vegetables
        ''';

        const singleFoodResponse = '''
        One banana contains:
        Calories: 105 kcal
        Carbs: 27g
        Fiber: 3g
        ''';

        final recipeResult = validator.validateResponse(recipeResponse);
        final singleResult = validator.validateResponse(singleFoodResponse);

        expect(recipeResult.isValid, true);
        expect(singleResult.isValid, true);
      });

      test('should handle responses with ranges and approximations', () {
        const rangeResponse = '''
        This food contains approximately:
        - Calories: 200-250 kcal
        - Protein: 15-20g
        - Carbs: 25-30g
        - Fat: 8-12g
        ''';

        final result = validator.validateResponse(rangeResponse);
        expect(result.isValid, true);
        // Should handle ranges as valid nutrition information
      });
    });

    group('performance tests', () {
      test('should handle very long valid response efficiently', () {
        final longValidResponse = 'This is a valid nutrition response. ' * 200 +
            'It contains calories: 250, protein: 15g, carbs: 30g, fat: 8g.';
        
        final stopwatch = Stopwatch()..start();
        final result = validator.validateResponse(longValidResponse);
        stopwatch.stop();
        
        expect(result.isValid, true);
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
      });

      test('should handle response with many nutrition keywords efficiently', () {
        final response = 'calories protein carbs fat fiber vitamin mineral ' +
            'nutrition diet food meal recipe ingredient ' * 50;
        
        final stopwatch = Stopwatch()..start();
        final result = validator.validateResponse(response);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle batch validation efficiently', () {
        final responses = List.generate(50, (index) => 
            'Food item $index contains ${100 + index} calories and ${10 + index}g protein.');

        final stopwatch = Stopwatch()..start();
        final results = responses.map((r) => validator.validateResponse(r)).toList();
        stopwatch.stop();

        expect(results.length, 50);
        expect(results.every((r) => r.isValid), true);
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should handle batch efficiently
      });
    });
  });
}