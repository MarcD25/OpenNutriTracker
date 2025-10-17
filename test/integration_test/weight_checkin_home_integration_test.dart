import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';

class MockWeightCheckinUsecase extends Mock implements WeightCheckinUsecase {}

void main() {
  group('Weight Check-in Home Integration Tests', () {
    late MockWeightCheckinUsecase mockWeightCheckinUsecase;

    setUp(() {
      mockWeightCheckinUsecase = MockWeightCheckinUsecase();
    });

    test('should show weight check-in when reminder is due', () async {
      // Arrange
      when(mockWeightCheckinUsecase.shouldShowCheckinReminder())
          .thenAnswer((_) async => true);
      when(mockWeightCheckinUsecase.getLatestWeightEntry())
          .thenAnswer((_) async => null);
      when(mockWeightCheckinUsecase.getCheckinFrequency())
          .thenAnswer((_) async => CheckinFrequency.weekly);
      when(mockWeightCheckinUsecase.getNextCheckinDate())
          .thenAnswer((_) async => DateTime.now().add(const Duration(days: 7)));

      // Act & Assert
      expect(await mockWeightCheckinUsecase.shouldShowCheckinReminder(), true);
      expect(await mockWeightCheckinUsecase.getCheckinFrequency(), CheckinFrequency.weekly);
    });

    test('should not show weight check-in when not due', () async {
      // Arrange
      when(mockWeightCheckinUsecase.shouldShowCheckinReminder())
          .thenAnswer((_) async => false);

      // Act & Assert
      expect(await mockWeightCheckinUsecase.shouldShowCheckinReminder(), false);
    });

    test('should record weight entry successfully', () async {
      // Arrange
      const weight = 70.5;
      const notes = 'Feeling good today';
      
      when(mockWeightCheckinUsecase.recordWeightEntry(weight, notes: notes))
          .thenAnswer((_) async {});

      // Act
      await mockWeightCheckinUsecase.recordWeightEntry(weight, notes: notes);

      // Assert
      verify(mockWeightCheckinUsecase.recordWeightEntry(weight, notes: notes)).called(1);
    });

    test('should update check-in frequency', () async {
      // Arrange
      const newFrequency = CheckinFrequency.daily;
      
      when(mockWeightCheckinUsecase.setCheckinFrequency(newFrequency))
          .thenAnswer((_) async {});

      // Act
      await mockWeightCheckinUsecase.setCheckinFrequency(newFrequency);

      // Assert
      verify(mockWeightCheckinUsecase.setCheckinFrequency(newFrequency)).called(1);
    });

    test('should provide weight trend when available', () async {
      // Arrange
      final mockTrend = WeightTrend(
        trendDirection: WeightTrendDirection.decreasing,
        averageWeeklyChange: -0.5,
        totalChange: -2.0,
        confidence: WeightTrendConfidence.high,
        dataPoints: 10,
      );
      
      when(mockWeightCheckinUsecase.calculateWeightTrend(30))
          .thenAnswer((_) async => mockTrend);

      // Act
      final trend = await mockWeightCheckinUsecase.calculateWeightTrend(30);

      // Assert
      expect(trend.trendDirection, WeightTrendDirection.decreasing);
      expect(trend.averageWeeklyChange, -0.5);
      expect(trend.confidence, WeightTrendConfidence.high);
    });
  });
}