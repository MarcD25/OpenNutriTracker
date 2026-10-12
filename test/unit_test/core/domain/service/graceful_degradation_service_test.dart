import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/core/domain/service/graceful_degradation_service.dart';

void main() {
  group('GracefulDegradationService', () {
    late GracefulDegradationService service;

    setUp(() {
      service = GracefulDegradationService();
      service.resetAllFeatureStatuses(); // Start with clean state
    });

    group('executeWithFallback', () {
      test('should return primary result when operation succeeds', () async {
        final result = await service.executeWithFallback<String>(
          featureName: 'test_feature',
          primaryOperation: () async => 'primary_result',
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('primary_result'));
        expect(service.isFeatureDisabled('test_feature'), isFalse);
      });

      test('should return fallback result when operation fails', () async {
        final result = await service.executeWithFallback<String>(
          featureName: 'test_feature',
          primaryOperation: () async => throw Exception('test error'),
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('fallback_result'));
        expect(service.isFeatureDisabled('test_feature'), isTrue);
      });

      test('should use fallback immediately if feature is already disabled', () async {
        // First, disable the feature
        service.disableFeature('test_feature');

        final result = await service.executeWithFallback<String>(
          featureName: 'test_feature',
          primaryOperation: () async => throw Exception('should not be called'),
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('fallback_result'));
      });

      test('should handle timeout correctly', () async {
        final result = await service.executeWithFallback<String>(
          featureName: 'test_feature',
          primaryOperation: () async {
            await Future.delayed(const Duration(seconds: 2));
            return 'primary_result';
          },
          fallbackOperation: () => 'fallback_result',
          timeout: const Duration(milliseconds: 100),
        );

        expect(result, equals('fallback_result'));
        expect(service.isFeatureDisabled('test_feature'), isTrue);
      });
    });

    group('executeWithFallbackSync', () {
      test('should return primary result when operation succeeds', () {
        final result = service.executeWithFallbackSync<String>(
          featureName: 'test_feature',
          primaryOperation: () => 'primary_result',
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('primary_result'));
        expect(service.isFeatureDisabled('test_feature'), isFalse);
      });

      test('should return fallback result when operation fails', () {
        final result = service.executeWithFallbackSync<String>(
          featureName: 'test_feature',
          primaryOperation: () => throw Exception('test error'),
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('fallback_result'));
        expect(service.isFeatureDisabled('test_feature'), isTrue);
      });

      test('should use fallback immediately if feature is already disabled', () {
        // First, disable the feature
        service.disableFeature('test_feature');

        final result = service.executeWithFallbackSync<String>(
          featureName: 'test_feature',
          primaryOperation: () => throw Exception('should not be called'),
          fallbackOperation: () => 'fallback_result',
        );

        expect(result, equals('fallback_result'));
      });
    });

    group('specific error handlers', () {
      test('handleLogisticsFailure should not throw', () async {
        expect(
          () async => await service.handleLogisticsFailure('test_operation', Exception('test error')),
          returnsNormally,
        );
      });

      test('handleLLMValidationFailure should return original response', () {
        const originalResponse = 'original response';
        const error = ValidationException(
          'validation failed',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
        );

        final result = service.handleLLMValidationFailure(originalResponse, error);
        expect(result, equals(originalResponse));
      });

      test('handleBMICalculationFailure should return calculated BMI or default', () {
        // Test with valid inputs
        final result1 = service.handleBMICalculationFailure(1.75, 70.0, Exception('test error'));
        expect(result1, closeTo(22.86, 0.01)); // 70 / (1.75^2)

        // Test with invalid inputs
        final result2 = service.handleBMICalculationFailure(0.0, 70.0, Exception('test error'));
        expect(result2, equals(25.0)); // Default BMI
      });

      test('handleCalorieCalculationFailure should return fallback or default', () {
        // Test with provided fallback
        final result1 = service.handleCalorieCalculationFailure(
          Exception('test error'),
          fallbackValue: 2500.0,
        );
        expect(result1, equals(2500.0));

        // Test with default fallback
        final result2 = service.handleCalorieCalculationFailure(Exception('test error'));
        expect(result2, equals(2000.0));
      });

      test('handleWeightCheckinFailure should return false', () async {
        final result = await service.handleWeightCheckinFailure(Exception('test error'));
        expect(result, isFalse);
      });

      test('handleNotificationFailure should return false', () async {
        final result = await service.handleNotificationFailure(Exception('test error'));
        expect(result, isFalse);
      });
    });

    group('feature status management', () {
      test('should track feature status correctly', () {
        expect(service.isFeatureDisabled('test_feature'), isFalse);

        service.disableFeature('test_feature');
        expect(service.isFeatureDisabled('test_feature'), isTrue);

        service.enableFeature('test_feature');
        expect(service.isFeatureDisabled('test_feature'), isFalse);
      });

      test('should reset feature status', () {
        service.disableFeature('test_feature');
        expect(service.isFeatureDisabled('test_feature'), isTrue);

        service.resetFeatureStatus('test_feature');
        expect(service.isFeatureDisabled('test_feature'), isFalse);
      });

      test('should reset all feature statuses', () {
        service.disableFeature('feature1');
        service.disableFeature('feature2');
        expect(service.isFeatureDisabled('feature1'), isTrue);
        expect(service.isFeatureDisabled('feature2'), isTrue);

        service.resetAllFeatureStatuses();
        expect(service.isFeatureDisabled('feature1'), isFalse);
        expect(service.isFeatureDisabled('feature2'), isFalse);
      });

      test('should get feature statuses', () {
        service.disableFeature('feature1');
        service.enableFeature('feature2');

        final statuses = service.getFeatureStatuses();
        expect(statuses['feature1'], isFalse);
        expect(statuses['feature2'], isTrue);
      });
    });

    group('error logging', () {
      test('should not throw when logging fails', () async {
        // This test ensures that logging failures don't break the graceful degradation
        expect(
          () async => await service.executeWithFallback<String>(
            featureName: 'test_feature',
            primaryOperation: () async => throw Exception('test error'),
            fallbackOperation: () => 'fallback_result',
            logFailure: true,
          ),
          returnsNormally,
        );
      });

      test('should work without logging when disabled', () async {
        final result = await service.executeWithFallback<String>(
          featureName: 'test_feature',
          primaryOperation: () async => throw Exception('test error'),
          fallbackOperation: () => 'fallback_result',
          logFailure: false,
        );

        expect(result, equals('fallback_result'));
      });
    });
  });
}