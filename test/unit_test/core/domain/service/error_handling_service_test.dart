import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/core/domain/service/error_handling_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ErrorHandlingService', () {
    late ErrorHandlingService errorHandlingService;

    setUp(() {
      errorHandlingService = ErrorHandlingService();
    });

    group('handleWithGracefulDegradation', () {
      test('should return result when operation succeeds', () {
        final result = ErrorHandlingService.handleWithGracefulDegradation<String>(
          () => 'success',
          'fallback',
          operationName: 'test operation',
        );

        expect(result, equals('success'));
      });

      test('should return fallback when operation fails', () {
        final result = ErrorHandlingService.handleWithGracefulDegradation<String>(
          () => throw Exception('test error'),
          'fallback',
          operationName: 'test operation',
        );

        expect(result, equals('fallback'));
      });

      test('should return fallback when operation throws AppException', () {
        final result = ErrorHandlingService.handleWithGracefulDegradation<String>(
          () => throw const ValidationException(
            'validation failed',
            ValidationSeverity.error,
            [ValidationIssue.missingRequiredData],
          ),
          'fallback',
          operationName: 'test operation',
        );

        expect(result, equals('fallback'));
      });
    });

    group('handleAsyncWithGracefulDegradation', () {
      test('should return result when async operation succeeds', () async {
        final result = await ErrorHandlingService.handleAsyncWithGracefulDegradation<String>(
          () async => 'success',
          'fallback',
          operationName: 'test async operation',
        );

        expect(result, equals('success'));
      });

      test('should return fallback when async operation fails', () async {
        final result = await ErrorHandlingService.handleAsyncWithGracefulDegradation<String>(
          () async => throw Exception('test error'),
          'fallback',
          operationName: 'test async operation',
        );

        expect(result, equals('fallback'));
      });

      test('should return fallback when async operation throws AppException', () async {
        final result = await ErrorHandlingService.handleAsyncWithGracefulDegradation<String>(
          () async => throw const WeightCheckinException('weight save failed'),
          'fallback',
          operationName: 'test async operation',
        );

        expect(result, equals('fallback'));
      });
    });

    group('ValidationException', () {
      test('should create ValidationException with all properties', () {
        const exception = ValidationException(
          'test message',
          ValidationSeverity.warning,
          [ValidationIssue.unrealisticCalories, ValidationIssue.missingRequiredData],
          correctedValue: 'corrected',
          code: 'TEST_001',
        );

        expect(exception.message, equals('test message'));
        expect(exception.severity, equals(ValidationSeverity.warning));
        expect(exception.issues, contains(ValidationIssue.unrealisticCalories));
        expect(exception.issues, contains(ValidationIssue.missingRequiredData));
        expect(exception.correctedValue, equals('corrected'));
        expect(exception.code, equals('TEST_001'));
      });

      test('should have correct toString representation', () {
        const exception = ValidationException(
          'test message',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
        );

        expect(
          exception.toString(),
          equals('ValidationException: test message (Severity: ValidationSeverity.error)'),
        );
      });

      test('should implement equality correctly', () {
        const exception1 = ValidationException(
          'test message',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
          correctedValue: 'corrected',
        );

        const exception2 = ValidationException(
          'test message',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
          correctedValue: 'corrected',
        );

        const exception3 = ValidationException(
          'different message',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
          correctedValue: 'corrected',
        );

        expect(exception1, equals(exception2));
        expect(exception1, isNot(equals(exception3)));
      });
    });

    group('Other AppExceptions', () {
      test('should create LogisticsException', () {
        const exception = LogisticsException(
          'logistics failed',
          code: 'LOG_001',
        );

        expect(exception.message, equals('logistics failed'));
        expect(exception.code, equals('LOG_001'));
        expect(exception, isA<AppException>());
      });

      test('should create WeightCheckinException', () {
        const exception = WeightCheckinException(
          'weight checkin failed',
          code: 'WEIGHT_001',
        );

        expect(exception.message, equals('weight checkin failed'));
        expect(exception.code, equals('WEIGHT_001'));
        expect(exception, isA<AppException>());
      });

      test('should create CalorieCalculationException', () {
        const exception = CalorieCalculationException(
          'calorie calculation failed',
          code: 'CAL_001',
        );

        expect(exception.message, equals('calorie calculation failed'));
        expect(exception.code, equals('CAL_001'));
        expect(exception, isA<AppException>());
      });

      test('should create NotificationException', () {
        const exception = NotificationException(
          'notification failed',
          code: 'NOTIF_001',
        );

        expect(exception.message, equals('notification failed'));
        expect(exception.code, equals('NOTIF_001'));
        expect(exception, isA<AppException>());
      });
    });

    group('ValidationSeverity', () {
      test('should have all expected severity levels', () {
        expect(ValidationSeverity.values, hasLength(4));
        expect(ValidationSeverity.values, contains(ValidationSeverity.info));
        expect(ValidationSeverity.values, contains(ValidationSeverity.warning));
        expect(ValidationSeverity.values, contains(ValidationSeverity.error));
        expect(ValidationSeverity.values, contains(ValidationSeverity.critical));
      });
    });

    group('ValidationIssue', () {
      test('should have all expected validation issues', () {
        expect(ValidationIssue.values, hasLength(10));
        expect(ValidationIssue.values, contains(ValidationIssue.responseTooLarge));
        expect(ValidationIssue.values, contains(ValidationIssue.missingNutritionInfo));
        expect(ValidationIssue.values, contains(ValidationIssue.unrealisticCalories));
        expect(ValidationIssue.values, contains(ValidationIssue.incompleteResponse));
        expect(ValidationIssue.values, contains(ValidationIssue.formatError));
        expect(ValidationIssue.values, contains(ValidationIssue.invalidWeight));
        expect(ValidationIssue.values, contains(ValidationIssue.invalidBMI));
        expect(ValidationIssue.values, contains(ValidationIssue.unrealisticExerciseCalories));
        expect(ValidationIssue.values, contains(ValidationIssue.missingRequiredData));
        expect(ValidationIssue.values, contains(ValidationIssue.dataCorruption));
      });
    });
  });
}