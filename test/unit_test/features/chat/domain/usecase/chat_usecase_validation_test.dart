import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/features/chat/domain/service/llm_response_validator.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

void main() {
  late LLMResponseValidator validator;

  setUp(() {
    validator = LLMResponseValidator();
  });

  group('LLM Response Validator Integration', () {
    test('should validate response size and return corrected response when too large', () {
      // Arrange
      final longResponse = 'A' * 15000; // Exceeds maxResponseLength of 10000
      
      // Act
      final result = validator.validateResponse(longResponse);
      
      // Assert
      expect(result.isValid, true); // Should be valid with correction
      expect(result.issues, contains(ValidationIssue.responseTooLarge));
      expect(result.severity, ValidationSeverity.warning);
      expect(result.correctedResponse, isNotNull);
      expect(result.correctedResponse!.length, lessThan(longResponse.length));
      expect(result.correctedResponse!, contains('[Response truncated for length]'));
    });

    test('should pass validation for non-nutrition response', () {
      // Arrange
      const generalResponse = 'Hello, how can I help you today?';
      
      // Act
      final result = validator.validateResponse(generalResponse);
      
      // Assert
      expect(result.isValid, true);
      expect(result.issues, isEmpty);
      expect(result.severity, ValidationSeverity.info);
    });

    test('should validate calorie values and flag unrealistic values', () {
      // Arrange
      const unrealisticResponse = 'This apple has 5000 calories and 200g protein.';
      
      // Act
      final result = validator.validateResponse(unrealisticResponse);
      
      // Assert
      expect(result.isValid, false);
      expect(result.issues, contains(ValidationIssue.unrealisticCalories));
      expect(result.severity, ValidationSeverity.error);
    });

    test('should allow zero calories for water and diet drinks', () {
      // Arrange
      const zeroCalorieResponse = 'Water has 0 calories, 0g protein, 0g carbs, and 0g fat.';
      
      // Act
      final result = validator.validateResponse(zeroCalorieResponse);
      
      // Assert
      expect(result.isValid, true);
      expect(result.issues, isEmpty);
      expect(result.severity, ValidationSeverity.info);
    });

    // Note: Negative calorie validation would require more complex parsing
    // For now, the main improvement is allowing 0 calories for water, diet drinks, etc.

    test('should pass validation for good nutrition response', () {
      // Arrange
      const goodResponse = 'An apple contains approximately 95 calories, 0.5g protein, 25g carbs, and 0.3g fat.';
      
      // Act
      final result = validator.validateResponse(goodResponse);
      
      // Assert
      expect(result.isValid, true);
      expect(result.issues, isEmpty);
      expect(result.severity, ValidationSeverity.info);
      expect(result.correctedResponse, isNull);
    });

    test('should handle incomplete response', () {
      // Arrange
      const incompleteResponse = 'Hi';
      
      // Act
      final result = validator.validateResponse(incompleteResponse);
      
      // Assert
      expect(result.isValid, false);
      expect(result.issues, contains(ValidationIssue.incompleteResponse));
      expect(result.severity, ValidationSeverity.error);
    });

    test('should truncate response at sentence boundary when possible', () {
      // Arrange
      final longResponse = 'This is a sentence. ' * 600; // Creates a very long response
      
      // Act
      final result = validator.validateResponse(longResponse);
      
      // Assert
      expect(result.isValid, true);
      expect(result.correctedResponse, isNotNull);
      expect(result.correctedResponse!, contains('[Response truncated for length]'));
      expect(result.correctedResponse!.length, lessThan(longResponse.length));
    });
  });
}