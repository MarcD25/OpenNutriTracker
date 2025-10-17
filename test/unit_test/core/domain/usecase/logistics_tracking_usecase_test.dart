import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:opennutritracker/core/data/data_source/logistics_data_source.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/core/domain/usecase/logistics_tracking_usecase.dart';

@GenerateMocks([LogisticsDataSource])
import 'logistics_tracking_usecase_test.mocks.dart';

void main() {
  late LogisticsTrackingUsecase logisticsTrackingUsecase;
  late MockLogisticsDataSource mockLogisticsDataSource;

  setUp(() {
    mockLogisticsDataSource = MockLogisticsDataSource();
    logisticsTrackingUsecase = LogisticsTrackingUsecase(mockLogisticsDataSource);
  });

  group('LogisticsTrackingUsecase', () {
    test('should track user action successfully', () async {
      // Arrange
      const eventType = LogisticsEventType.mealLogged;
      final data = {'meal_type': 'breakfast', 'calories': 300};
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackUserAction(eventType, data);

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track chat interaction with hashed content', () async {
      // Arrange
      const message = 'What should I eat for breakfast?';
      const response = 'I recommend oatmeal with fruits.';
      const responseTime = Duration(milliseconds: 1500);
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackChatInteraction(
        message, 
        response, 
        responseTime,
      );

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track navigation between screens', () async {
      // Arrange
      const fromScreen = 'HomePage';
      const toScreen = 'DiaryPage';
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackNavigation(fromScreen, toScreen);

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track meal logged with correct data', () async {
      // Arrange
      const mealType = 'breakfast';
      const itemCount = 3;
      const totalCalories = 450.5;
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackMealLogged(
        mealType, 
        itemCount, 
        totalCalories,
      );

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track exercise logged with duration and calories', () async {
      // Arrange
      const exerciseType = 'running';
      const duration = Duration(minutes: 30);
      const caloriesBurned = 250.0;
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackExerciseLogged(
        exerciseType, 
        duration, 
        caloriesBurned,
      );

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track weight checkin with weight and unit', () async {
      // Arrange
      const weight = 70.5;
      const unit = 'kg';
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackWeightCheckin(weight, unit);

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track settings changed with old and new values', () async {
      // Arrange
      const settingKey = 'theme';
      const oldValue = 'light';
      const newValue = 'dark';
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackSettingsChanged(
        settingKey, 
        oldValue, 
        newValue,
      );

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track goal updated with goal type and values', () async {
      // Arrange
      const goalType = 'calorie_goal';
      const oldGoal = 2000;
      const newGoal = 2200;
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackGoalUpdated(
        goalType, 
        oldGoal, 
        newGoal,
      );

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should track app launched', () async {
      // Arrange
      when(mockLogisticsDataSource.logUserAction(any))
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.trackAppLaunched();

      // Assert
      verify(mockLogisticsDataSource.logUserAction(any)).called(1);
    });

    test('should handle errors gracefully and not throw', () async {
      // Arrange
      const eventType = LogisticsEventType.mealLogged;
      final data = {'meal_type': 'breakfast'};
      
      when(mockLogisticsDataSource.logUserAction(any))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => logisticsTrackingUsecase.trackUserAction(eventType, data),
        returnsNormally,
      );
    });

    test('should trigger log rotation', () async {
      // Arrange
      when(mockLogisticsDataSource.rotateLogsIfNeeded())
          .thenAnswer((_) async => {});

      // Act
      await logisticsTrackingUsecase.rotateLogsIfNeeded();

      // Assert
      verify(mockLogisticsDataSource.rotateLogsIfNeeded()).called(1);
    });

    group('data encryption and privacy', () {
      test('should hash sensitive content in chat interactions', () async {
        // Arrange
        const message = 'My weight is 70kg and I want to lose weight';
        const response = 'Based on your weight, here are some recommendations';
        const responseTime = Duration(milliseconds: 1500);
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackChatInteraction(
          message, 
          response, 
          responseTime,
        );

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        // Should contain hashed versions, not original content
        expect(loggedEvent.eventData.containsKey('message_hash'), true);
        expect(loggedEvent.eventData.containsKey('response_hash'), true);
        expect(loggedEvent.eventData.containsKey('message'), false);
        expect(loggedEvent.eventData.containsKey('response'), false);
      });

      test('should include metadata for chat interactions', () async {
        // Arrange
        const message = 'Test message';
        const response = 'Test response';
        const responseTime = Duration(milliseconds: 1000);
        const userId = 'user123';
        final additionalMetadata = {'session_type': 'nutrition_chat'};
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackChatInteraction(
          message, 
          response, 
          responseTime,
          userId: userId,
          additionalMetadata: additionalMetadata,
        );

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.userId, equals(userId));
        expect(loggedEvent.metadata!['interaction_type'], equals('chat'));
        expect(loggedEvent.metadata!['session_type'], equals('nutrition_chat'));
        expect(loggedEvent.metadata!.containsKey('session_id'), true);
      });
    });

    group('event data validation', () {
      test('should include correct data for meal logging', () async {
        // Arrange
        const mealType = 'breakfast';
        const itemCount = 3;
        const totalCalories = 450.5;
        const userId = 'user123';
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackMealLogged(
          mealType, 
          itemCount, 
          totalCalories,
          userId: userId,
        );

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.eventType, LogisticsEventType.mealLogged);
        expect(loggedEvent.eventData['meal_type'], equals(mealType));
        expect(loggedEvent.eventData['item_count'], equals(itemCount));
        expect(loggedEvent.eventData['total_calories'], equals(totalCalories));
        expect(loggedEvent.eventData.containsKey('timestamp'), true);
        expect(loggedEvent.userId, equals(userId));
        expect(loggedEvent.metadata!['action_type'], equals('meal_logging'));
        expect(loggedEvent.metadata!['nutrition_tracking'], true);
      });

      test('should include correct data for exercise logging', () async {
        // Arrange
        const exerciseType = 'running';
        const duration = Duration(minutes: 30);
        const caloriesBurned = 250.0;
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackExerciseLogged(
          exerciseType, 
          duration, 
          caloriesBurned,
        );

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.eventData['exercise_type'], equals(exerciseType));
        expect(loggedEvent.eventData['duration_minutes'], equals(30));
        expect(loggedEvent.eventData['calories_burned'], equals(caloriesBurned));
        expect(loggedEvent.metadata!['action_type'], equals('exercise_logging'));
        expect(loggedEvent.metadata!['fitness_tracking'], true);
      });

      test('should include correct data for weight checkin', () async {
        // Arrange
        const weight = 70.5;
        const unit = 'kg';
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackWeightCheckin(weight, unit);

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.eventData['weight_value'], equals(weight));
        expect(loggedEvent.eventData['weight_unit'], equals(unit));
        expect(loggedEvent.metadata!['action_type'], equals('weight_checkin'));
        expect(loggedEvent.metadata!['health_tracking'], true);
      });

      test('should include platform information for navigation', () async {
        // Arrange
        const fromScreen = 'HomePage';
        const toScreen = 'DiaryPage';
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackNavigation(fromScreen, toScreen);

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.eventData['from_screen'], equals(fromScreen));
        expect(loggedEvent.eventData['to_screen'], equals(toScreen));
        expect(loggedEvent.metadata!['navigation_type'], equals('screen_change'));
        expect(loggedEvent.metadata!.containsKey('platform'), true);
      });
    });

    group('analytics data generation', () {
      test('should generate analytics data with correct structure', () async {
        // Arrange
        final mockLogs = [
          _createMockLogEvent(LogisticsEventType.mealLogged, DateTime.now().subtract(const Duration(days: 1))),
          _createMockLogEvent(LogisticsEventType.chatInteraction, DateTime.now().subtract(const Duration(days: 2))),
          _createMockLogEvent(LogisticsEventType.exerciseLogged, DateTime.now().subtract(const Duration(days: 3))),
        ];
        
        when(mockLogisticsDataSource.getLogsByDateRange(any, any))
            .thenAnswer((_) async => mockLogs);

        // Act
        final analytics = await logisticsTrackingUsecase.getAnalyticsData();

        // Assert
        expect(analytics['total_events'], equals(3));
        expect(analytics.containsKey('date_range'), true);
        expect(analytics.containsKey('event_types'), true);
        expect(analytics.containsKey('daily_activity'), true);
        expect(analytics.containsKey('user_engagement'), true);
      });

      test('should handle empty analytics data gracefully', () async {
        // Arrange
        when(mockLogisticsDataSource.getLogsByDateRange(any, any))
            .thenAnswer((_) async => []);

        // Act
        final analytics = await logisticsTrackingUsecase.getAnalyticsData();

        // Assert
        expect(analytics['total_events'], equals(0));
        expect(analytics.containsKey('event_types'), true);
        expect(analytics.containsKey('daily_activity'), true);
        expect(analytics.containsKey('user_engagement'), true);
      });

      test('should handle analytics errors gracefully', () async {
        // Arrange
        when(mockLogisticsDataSource.getLogsByDateRange(any, any))
            .thenThrow(Exception('Database error'));

        // Act
        final analytics = await logisticsTrackingUsecase.getAnalyticsData();

        // Assert
        expect(analytics, isEmpty);
      });
    });

    group('event ID and session generation', () {
      test('should generate unique event IDs for multiple calls', () async {
        // Arrange
        const eventType = LogisticsEventType.mealLogged;
        final data = {'meal_type': 'breakfast'};
        final capturedEvents = <LogisticsEventEntity>[];
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((invocation) async {
              capturedEvents.add(invocation.positionalArguments[0] as LogisticsEventEntity);
            });

        // Act
        await logisticsTrackingUsecase.trackUserAction(eventType, data);
        await logisticsTrackingUsecase.trackUserAction(eventType, data);
        await logisticsTrackingUsecase.trackUserAction(eventType, data);

        // Assert
        expect(capturedEvents.length, equals(3));
        final eventIds = capturedEvents.map((e) => e.id).toSet();
        expect(eventIds.length, equals(3)); // All IDs should be unique
      });

      test('should generate session IDs for chat interactions', () async {
        // Arrange
        const message = 'Test message';
        const response = 'Test response';
        const responseTime = Duration(milliseconds: 1000);
        
        when(mockLogisticsDataSource.logUserAction(any))
            .thenAnswer((_) async => {});

        // Act
        await logisticsTrackingUsecase.trackChatInteraction(message, response, responseTime);

        // Assert
        final captured = verify(mockLogisticsDataSource.logUserAction(captureAny)).captured;
        final loggedEvent = captured.first as LogisticsEventEntity;
        
        expect(loggedEvent.metadata!.containsKey('session_id'), true);
        expect(loggedEvent.metadata!['session_id'], isA<String>());
        expect((loggedEvent.metadata!['session_id'] as String).isNotEmpty, true);
      });
    });

    group('error resilience', () {
      test('should handle multiple consecutive errors without throwing', () async {
        // Arrange
        when(mockLogisticsDataSource.logUserAction(any))
            .thenThrow(Exception('Persistent error'));

        // Act & Assert - should not throw for any of these
        expect(
          () => logisticsTrackingUsecase.trackUserAction(LogisticsEventType.mealLogged, {}),
          returnsNormally,
        );
        expect(
          () => logisticsTrackingUsecase.trackChatInteraction('msg', 'resp', const Duration(seconds: 1)),
          returnsNormally,
        );
        expect(
          () => logisticsTrackingUsecase.trackNavigation('from', 'to'),
          returnsNormally,
        );
        expect(
          () => logisticsTrackingUsecase.trackAppLaunched(),
          returnsNormally,
        );
      });

      test('should handle log rotation errors gracefully', () async {
        // Arrange
        when(mockLogisticsDataSource.rotateLogsIfNeeded())
            .thenThrow(Exception('Rotation failed'));

        // Act & Assert
        expect(
          () => logisticsTrackingUsecase.rotateLogsIfNeeded(),
          returnsNormally,
        );
      });
    });
  });

  // Helper method to create mock log events for testing
  dynamic _createMockLogEvent(LogisticsEventType eventType, DateTime timestamp) {
    return MockLogEvent(eventType, timestamp);
  }
}

// Mock class for testing analytics
class MockLogEvent {
  final LogisticsEventType eventType;
  final DateTime timestamp;
  
  MockLogEvent(this.eventType, this.timestamp);
}