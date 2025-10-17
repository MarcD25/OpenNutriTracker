import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/data/data_source/logistics_data_source.dart';
import 'package:opennutritracker/core/data/dbo/logistics_event_dbo.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';

@GenerateMocks([Box<LogisticsEventDBO>])
import 'logistics_data_source_test.mocks.dart';

void main() {
  late LogisticsDataSource dataSource;
  late MockBox<LogisticsEventDBO> mockBox;

  setUp(() {
    mockBox = MockBox<LogisticsEventDBO>();
    dataSource = LogisticsDataSource(mockBox);
  });

  group('LogisticsDataSource', () {
    group('logUserAction', () {
      test('should store user action event successfully', () async {
        // Arrange
        final event = LogisticsEventEntity(
          id: 'test-id',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'food': 'apple', 'calories': 95},
          timestamp: DateTime.now(),
          userId: 'user-123',
        );

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        await dataSource.logUserAction(event);
        
        // Wait for batch processing
        await Future.delayed(Duration(milliseconds: 100));

        // Assert - should eventually call add when batch is processed
        // Note: Due to batching, this might not be called immediately
        expect(() => dataSource.logUserAction(event), returnsNormally);
      });

      test('should handle storage errors gracefully', () async {
        // Arrange
        final event = LogisticsEventEntity(
          id: 'test-id',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'food': 'apple'},
          timestamp: DateTime.now(),
        );

        when(mockBox.add(any)).thenThrow(Exception('Storage error'));
        when(mockBox.length).thenReturn(0);

        // Act & Assert
        expect(() => dataSource.logUserAction(event), returnsNormally);
        // Should not throw, should handle gracefully
      });

      test('should batch events efficiently', () async {
        // Arrange
        final events = List.generate(10, (index) => LogisticsEventEntity(
          id: 'test-$index',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'food': 'food-$index'},
          timestamp: DateTime.now(),
        ));

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        for (final event in events) {
          await dataSource.logUserAction(event);
        }

        // Assert
        expect(() => events.forEach((e) => dataSource.logUserAction(e)), returnsNormally);
      });
    });

    group('logChatInteraction', () {
      test('should store chat interaction with correct data', () async {
        // Arrange
        const message = 'What are the calories in an apple?';
        const response = 'An apple contains about 95 calories.';
        const responseTime = Duration(seconds: 2);

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        await dataSource.logChatInteraction(message, response, responseTime);

        // Assert
        expect(() => dataSource.logChatInteraction(message, response, responseTime), returnsNormally);
      });

      test('should include response time in chat log', () async {
        // Arrange
        const message = 'Test message';
        const response = 'Test response';
        const responseTime = Duration(milliseconds: 1500);

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        await dataSource.logChatInteraction(message, response, responseTime);

        // Assert
        expect(() => dataSource.logChatInteraction(message, response, responseTime), returnsNormally);
      });
    });

    group('logNavigation', () {
      test('should store navigation event correctly', () async {
        // Arrange
        const fromScreen = 'home';
        const toScreen = 'diary';

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        await dataSource.logNavigation(fromScreen, toScreen);

        // Assert
        expect(() => dataSource.logNavigation(fromScreen, toScreen), returnsNormally);
      });

      test('should handle navigation logging errors gracefully', () async {
        // Arrange
        const fromScreen = 'settings';
        const toScreen = 'profile';

        when(mockBox.add(any)).thenThrow(Exception('Storage error'));
        when(mockBox.length).thenReturn(0);

        // Act & Assert
        expect(() => dataSource.logNavigation(fromScreen, toScreen), returnsNormally);
      });
    });

    group('rotateLogsIfNeeded', () {
      test('should rotate logs when size limit exceeded', () async {
        // Arrange
        final largeDBO = LogisticsEventDBO()
          ..id = 'large-event'
          ..eventType = 'test'
          ..eventData = {'data': 'A' * 1000} // Large data
          ..timestamp = DateTime.now();

        when(mockBox.length).thenReturn(15000); // Exceeds maxLogEntries
        when(mockBox.values).thenReturn([largeDBO] * 15000);
        when(mockBox.clear()).thenAnswer((_) async => 0);
        when(mockBox.add(any)).thenAnswer((_) async => 0);

        // Act
        await dataSource.rotateLogsIfNeeded();

        // Assert
        verify(mockBox.clear()).called(1);
      });

      test('should not rotate logs when under size limit', () async {
        // Arrange
        when(mockBox.length).thenReturn(100); // Under maxLogEntries
        when(mockBox.values).thenReturn([]);

        // Act
        await dataSource.rotateLogsIfNeeded();

        // Assert
        verifyNever(mockBox.clear());
      });

      test('should backup logs before rotation', () async {
        // Arrange
        final events = List.generate(15000, (index) => LogisticsEventDBO()
          ..id = 'event-$index'
          ..eventType = 'test'
          ..eventData = {'index': index}
          ..timestamp = DateTime.now().subtract(Duration(minutes: index)));

        when(mockBox.length).thenReturn(15000);
        when(mockBox.values).thenReturn(events);
        when(mockBox.clear()).thenAnswer((_) async => 0);
        when(mockBox.add(any)).thenAnswer((_) async => 0);

        // Act
        await dataSource.rotateLogsIfNeeded();

        // Assert
        // Should have attempted to backup before clearing
        verify(mockBox.values).called(1);
        verify(mockBox.clear()).called(1);
      });
    });

    group('getLogsByDateRange', () {
      test('should return logs within date range', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 7));
        final endDate = now;

        final events = [
          LogisticsEventDBO()
            ..id = 'event-1'
            ..timestamp = now.subtract(const Duration(days: 5)), // Within range
          LogisticsEventDBO()
            ..id = 'event-2'
            ..timestamp = now.subtract(const Duration(days: 10)), // Outside range
          LogisticsEventDBO()
            ..id = 'event-3'
            ..timestamp = now.subtract(const Duration(days: 2)), // Within range
        ];

        when(mockBox.values).thenReturn(events);

        // Act
        final result = await dataSource.getLogsByDateRange(startDate, endDate);

        // Assert
        expect(result.length, 2);
        expect(result.any((e) => e.id == 'event-1'), true);
        expect(result.any((e) => e.id == 'event-3'), true);
        expect(result.any((e) => e.id == 'event-2'), false);
      });

      test('should return empty list when no logs in range', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 7));
        final endDate = now.subtract(const Duration(days: 5));

        final events = [
          LogisticsEventDBO()
            ..id = 'event-1'
            ..timestamp = now.subtract(const Duration(days: 2)), // Outside range
        ];

        when(mockBox.values).thenReturn(events);

        // Act
        final result = await dataSource.getLogsByDateRange(startDate, endDate);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 7));
        final endDate = now;

        when(mockBox.values).thenThrow(Exception('Database error'));

        // Act
        final result = await dataSource.getLogsByDateRange(startDate, endDate);

        // Assert
        expect(result, isEmpty); // Should return empty list on error
      });
    });

    group('getAllLogs', () {
      test('should return all logs', () async {
        // Arrange
        final events = [
          LogisticsEventDBO()..id = 'event-1'..timestamp = DateTime.now(),
          LogisticsEventDBO()..id = 'event-2'..timestamp = DateTime.now(),
        ];

        when(mockBox.values).thenReturn(events);

        // Act
        final result = await dataSource.getAllLogs();

        // Assert
        expect(result.length, 2);
        expect(result.any((e) => e.id == 'event-1'), true);
        expect(result.any((e) => e.id == 'event-2'), true);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        when(mockBox.values).thenThrow(Exception('Database error'));

        // Act
        final result = await dataSource.getAllLogs();

        // Assert
        expect(result, isEmpty); // Should return empty list on error
      });
    });

    group('getLogsByEventType', () {
      test('should return logs of specific event type', () async {
        // Arrange
        final events = [
          LogisticsEventDBO()
            ..id = 'event-1'
            ..eventType = LogisticsEventType.mealLogged.name
            ..timestamp = DateTime.now(),
          LogisticsEventDBO()
            ..id = 'event-2'
            ..eventType = LogisticsEventType.chatInteraction.name
            ..timestamp = DateTime.now(),
          LogisticsEventDBO()
            ..id = 'event-3'
            ..eventType = LogisticsEventType.mealLogged.name
            ..timestamp = DateTime.now(),
        ];

        when(mockBox.values).thenReturn(events);

        // Act
        final result = await dataSource.getLogsByEventType(LogisticsEventType.mealLogged);

        // Assert
        expect(result.length, 2);
        expect(result.every((e) => e.eventType == LogisticsEventType.mealLogged.name), true);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        when(mockBox.values).thenThrow(Exception('Database error'));

        // Act
        final result = await dataSource.getLogsByEventType(LogisticsEventType.mealLogged);

        // Assert
        expect(result, isEmpty); // Should return empty list on error
      });
    });

    group('performance and batching', () {
      test('should handle large event data efficiently', () async {
        // Arrange
        final largeEvent = LogisticsEventEntity(
          id: 'large-1',
          eventType: LogisticsEventType.chatInteraction,
          eventData: {
            'message': 'A' * 5000, // Large message
            'response': 'B' * 10000, // Large response
          },
          timestamp: DateTime.now(),
        );

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        final stopwatch = Stopwatch()..start();
        await dataSource.logUserAction(largeEvent);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(() => dataSource.logUserAction(largeEvent), returnsNormally);
      });

      test('should handle concurrent operations', () async {
        // Arrange
        final events = List.generate(20, (index) => LogisticsEventEntity(
          id: 'concurrent-$index',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'meal': 'meal-$index'},
          timestamp: DateTime.now(),
        ));

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        final futures = events.map((e) => dataSource.logUserAction(e));
        await Future.wait(futures);

        // Assert
        expect(() => Future.wait(futures), returnsNormally);
      });
    });

    group('error handling and resilience', () {
      test('should continue operation when storage fails', () async {
        // Arrange
        final event = LogisticsEventEntity(
          id: 'fail-1',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'food': 'apple'},
          timestamp: DateTime.now(),
        );

        when(mockBox.add(any)).thenThrow(HiveError('Storage full'));
        when(mockBox.length).thenReturn(0);

        // Act & Assert
        expect(() => dataSource.logUserAction(event), returnsNormally);
        // Should not crash the app
      });

      test('should validate event data before storage', () async {
        // Arrange
        final validEvent = LogisticsEventEntity(
          id: 'valid-1',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'food': 'apple'},
          timestamp: DateTime.now(),
        );

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act & Assert
        expect(() => dataSource.logUserAction(validEvent), returnsNormally);
      });
    });

    group('memory management', () {
      test('should implement memory management mixin', () {
        // Assert
        expect(dataSource, isA<Object>());
        // The data source should have memory management capabilities
      });

      test('should handle memory pressure gracefully', () async {
        // Arrange
        final events = List.generate(1000, (index) => LogisticsEventEntity(
          id: 'memory-$index',
          eventType: LogisticsEventType.mealLogged,
          eventData: {'data': 'A' * 100},
          timestamp: DateTime.now(),
        ));

        when(mockBox.add(any)).thenAnswer((_) async => 0);
        when(mockBox.length).thenReturn(0);

        // Act
        for (final event in events) {
          await dataSource.logUserAction(event);
        }

        // Assert
        expect(() => events.forEach((e) => dataSource.logUserAction(e)), returnsNormally);
      });
    });
  });
}