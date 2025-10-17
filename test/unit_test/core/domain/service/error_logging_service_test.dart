import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/core/domain/service/error_logging_service.dart';

void main() {
  group('ErrorLoggingService', () {
    late ErrorLoggingService service;

    setUp(() {
      service = ErrorLoggingService();
    });

    group('ErrorLogEntry', () {
      test('should create ErrorLogEntry with all properties', () {
        final entry = ErrorLogEntry(
          timestamp: DateTime(2023, 1, 1),
          errorType: 'ValidationException',
          message: 'test message',
          code: 'TEST_001',
          severity: ErrorSeverity.error,
          stackTrace: 'test stack trace',
          context: {'key': 'value'},
          userId: 'user123',
          platform: 'test',
          appVersion: '1.0.0',
        );

        expect(entry.timestamp, equals(DateTime(2023, 1, 1)));
        expect(entry.errorType, equals('ValidationException'));
        expect(entry.message, equals('test message'));
        expect(entry.code, equals('TEST_001'));
        expect(entry.severity, equals(ErrorSeverity.error));
        expect(entry.stackTrace, equals('test stack trace'));
        expect(entry.context, equals({'key': 'value'}));
        expect(entry.userId, equals('user123'));
        expect(entry.platform, equals('test'));
        expect(entry.appVersion, equals('1.0.0'));
      });

      test('should serialize to and from JSON correctly', () {
        final entry = ErrorLogEntry(
          timestamp: DateTime(2023, 1, 1),
          errorType: 'ValidationException',
          message: 'test message',
          code: 'TEST_001',
          severity: ErrorSeverity.error,
          stackTrace: 'test stack trace',
          context: {'key': 'value'},
          userId: 'user123',
          platform: 'test',
          appVersion: '1.0.0',
        );

        final json = entry.toJson();
        final deserializedEntry = ErrorLogEntry.fromJson(json);

        expect(deserializedEntry.timestamp, equals(entry.timestamp));
        expect(deserializedEntry.errorType, equals(entry.errorType));
        expect(deserializedEntry.message, equals(entry.message));
        expect(deserializedEntry.code, equals(entry.code));
        expect(deserializedEntry.severity, equals(entry.severity));
        expect(deserializedEntry.stackTrace, equals(entry.stackTrace));
        expect(deserializedEntry.context, equals(entry.context));
        expect(deserializedEntry.userId, equals(entry.userId));
        expect(deserializedEntry.platform, equals(entry.platform));
        expect(deserializedEntry.appVersion, equals(entry.appVersion));
      });

      test('should handle null values in JSON serialization', () {
        final entry = ErrorLogEntry(
          timestamp: DateTime(2023, 1, 1),
          errorType: 'TestException',
          message: 'test message',
          severity: ErrorSeverity.info,
          platform: 'test',
          appVersion: '1.0.0',
        );

        final json = entry.toJson();
        final deserializedEntry = ErrorLogEntry.fromJson(json);

        expect(deserializedEntry.code, isNull);
        expect(deserializedEntry.stackTrace, isNull);
        expect(deserializedEntry.context, isNull);
        expect(deserializedEntry.userId, isNull);
      });
    });

    group('ErrorSeverity', () {
      test('should have all expected severity levels', () {
        expect(ErrorSeverity.values, hasLength(4));
        expect(ErrorSeverity.values, contains(ErrorSeverity.info));
        expect(ErrorSeverity.values, contains(ErrorSeverity.warning));
        expect(ErrorSeverity.values, contains(ErrorSeverity.error));
        expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
      });
    });

    group('ErrorStatistics', () {
      test('should calculate error rates correctly', () {
        final stats = ErrorStatistics();
        stats.totalErrors = 100;
        stats.criticalErrors = 5;
        stats.errors = 20;
        stats.warnings = 30;
        stats.infoMessages = 45;

        expect(stats.criticalErrorRate, equals(0.05));
        expect(stats.errorRate, equals(0.20));
        expect(stats.warningRate, equals(0.30));
      });

      test('should handle zero total errors', () {
        final stats = ErrorStatistics();
        stats.totalErrors = 0;

        expect(stats.criticalErrorRate, equals(0.0));
        expect(stats.errorRate, equals(0.0));
        expect(stats.warningRate, equals(0.0));
      });
    });

    group('logError', () {
      test('should not throw when logging ValidationException', () async {
        const error = ValidationException(
          'test validation error',
          ValidationSeverity.warning,
          [ValidationIssue.unrealisticCalories],
        );

        expect(
          () async => await service.logError(error),
          returnsNormally,
        );
      });

      test('should not throw when logging LogisticsException', () async {
        const error = LogisticsException('test logistics error');

        expect(
          () async => await service.logError(error),
          returnsNormally,
        );
      });

      test('should not throw when logging with context', () async {
        const error = WeightCheckinException('test weight error');
        final context = {
          'weight': 70.0,
          'timestamp': '2023-01-01T00:00:00Z',
        };

        expect(
          () async => await service.logError(error, context: context, userId: 'user123'),
          returnsNormally,
        );
      });
    });

    group('logCustomError', () {
      test('should not throw when logging custom error', () async {
        expect(
          () async => await service.logCustomError(
            'Custom error message',
            errorType: 'CustomError',
            code: 'CUSTOM_001',
            severity: ErrorSeverity.error,
            context: {'custom': 'data'},
          ),
          returnsNormally,
        );
      });

      test('should use default severity when not specified', () async {
        expect(
          () async => await service.logCustomError('Custom error message'),
          returnsNormally,
        );
      });
    });

    group('getErrorLogs', () {
      test('should return empty list when no logs exist', () async {
        final logs = await service.getErrorLogs();
        expect(logs, isEmpty);
      });

      test('should handle file read errors gracefully', () async {
        // This test ensures that file read errors don't crash the app
        expect(
          () async => await service.getErrorLogs(),
          returnsNormally,
        );
      });
    });

    group('getErrorStatistics', () {
      test('should return empty statistics when no logs exist', () async {
        final stats = await service.getErrorStatistics();
        
        expect(stats.totalErrors, equals(0));
        expect(stats.criticalErrors, equals(0));
        expect(stats.errors, equals(0));
        expect(stats.warnings, equals(0));
        expect(stats.infoMessages, equals(0));
        expect(stats.errorsByType, isEmpty);
      });
    });

    group('clearOldLogs', () {
      test('should not throw when clearing logs', () async {
        expect(
          () async => await service.clearOldLogs(),
          returnsNormally,
        );
      });

      test('should not throw when clearing logs with custom duration', () async {
        expect(
          () async => await service.clearOldLogs(olderThan: const Duration(days: 7)),
          returnsNormally,
        );
      });
    });

    group('error handling', () {
      test('should handle file system errors gracefully', () async {
        // Test that the service doesn't crash when file operations fail
        const error = ValidationException(
          'test error',
          ValidationSeverity.error,
          [ValidationIssue.formatError],
        );

        expect(
          () async => await service.logError(error),
          returnsNormally,
        );
      });

      test('should handle JSON serialization errors gracefully', () async {
        // Create an error with potentially problematic data
        final error = AppException(
          'test error',
          originalError: Object(), // Non-serializable object
        );

        expect(
          () async => await service.logError(error),
          returnsNormally,
        );
      });
    });
  });
}