import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_validation_service.dart';

void main() {
  group('WeightValidationService', () {
    group('validateWeight', () {
      test('should validate normal weight in kg', () {
        final result = WeightValidationService.validateWeight(
          70.0,
          isKilograms: true,
        );

        expect(result.isValid, true);
        expect(result.severity, ValidationSeverity.none);
        expect(result.message, null);
      });

      test('should validate normal weight in lbs', () {
        final result = WeightValidationService.validateWeight(
          154.0,
          isKilograms: false,
        );

        expect(result.isValid, true);
        expect(result.severity, ValidationSeverity.none);
        expect(result.message, null);
      });

      test('should reject weight below minimum in kg', () {
        final result = WeightValidationService.validateWeight(
          15.0,
          isKilograms: true,
        );

        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
        expect(result.message, contains('between 20 and 300 kg'));
      });

      test('should reject weight above maximum in lbs', () {
        final result = WeightValidationService.validateWeight(
          700.0,
          isKilograms: false,
        );

        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.error);
        expect(result.message, contains('between 44 and 661 lbs'));
      });

      test('should warn about large weight change', () {
        final result = WeightValidationService.validateWeight(
          75.0,
          isKilograms: true,
          previousWeight: 70.0,
          daysSincePrevious: 1,
        );

        expect(result.isValid, false);
        expect(result.severity, ValidationSeverity.warning);
        expect(result.message, contains('large change'));
      });

      test('should provide info for moderate weight change', () {
        final result = WeightValidationService.validateWeight(
          71.5,
          isKilograms: true,
          previousWeight: 70.0,
          daysSincePrevious: 1,
        );

        expect(result.isValid, true);
        expect(result.severity, ValidationSeverity.info);
        expect(result.message, contains('Significant weight change'));
      });

      test('should accept gradual weight change', () {
        final result = WeightValidationService.validateWeight(
          70.5,
          isKilograms: true,
          previousWeight: 70.0,
          daysSincePrevious: 7,
        );

        expect(result.isValid, true);
        expect(result.severity, ValidationSeverity.none);
        expect(result.message, null);
      });
    });

    group('weight conversion', () {
      test('should convert lbs to kg correctly', () {
        final kg = WeightValidationService.convertLbsToKg(154.324);
        expect(kg, closeTo(70.0, 0.01));
      });

      test('should convert kg to lbs correctly', () {
        final lbs = WeightValidationService.convertKgToLbs(70.0);
        expect(lbs, closeTo(154.324, 0.01));
      });
    });

    group('weight formatting', () {
      test('should format weight in kg', () {
        final formatted = WeightValidationService.formatWeight(
          70.123,
          showInLbs: false,
        );
        expect(formatted, '70.1 kg');
      });

      test('should format weight in lbs', () {
        final formatted = WeightValidationService.formatWeight(
          70.0,
          showInLbs: true,
        );
        expect(formatted, '154.3 lbs');
      });
    });

    group('weight unit helpers', () {
      test('should return correct unit for kg', () {
        final unit = WeightValidationService.getWeightUnit(true);
        expect(unit, 'kg');
      });

      test('should return correct unit for lbs', () {
        final unit = WeightValidationService.getWeightUnit(false);
        expect(unit, 'lbs');
      });

      test('should validate weight string correctly', () {
        expect(WeightValidationService.isValidWeightString('70.5'), true);
        expect(WeightValidationService.isValidWeightString('70'), true);
        expect(WeightValidationService.isValidWeightString(''), false);
        expect(WeightValidationService.isValidWeightString('abc'), false);
        expect(WeightValidationService.isValidWeightString('-5'), false);
      });

      test('should round weight correctly', () {
        final rounded = WeightValidationService.roundWeight(70.156, true);
        expect(rounded, 70.2);
      });

      test('should provide correct decimal places', () {
        expect(WeightValidationService.getDecimalPlaces(true), 1);
        expect(WeightValidationService.getDecimalPlaces(false), 1);
      });

      test('should provide correct step size', () {
        expect(WeightValidationService.getStepSize(true), 0.1);
        expect(WeightValidationService.getStepSize(false), 0.1);
      });
    });
  });
}