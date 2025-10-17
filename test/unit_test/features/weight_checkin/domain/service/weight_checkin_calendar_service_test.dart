import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_calendar_service.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

import 'weight_checkin_calendar_service_test.mocks.dart';

@GenerateMocks([WeightCheckinUsecase])
void main() {
  late WeightCheckinCalendarService service;
  late MockWeightCheckinUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockWeightCheckinUsecase();
    service = WeightCheckinCalendarService(mockUsecase);
  });

  group('WeightCheckinCalendarService', () {
    group('isCheckinDay', () {
      testWidgets('should return true for daily frequency', (WidgetTester tester) async {
        // Arrange
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.daily);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => []);

        // Act
        final result = await service.isCheckinDay(DateTime(2024, 1, 15));

        // Assert
        expect(result, true);
      });

      testWidgets('should return correct days for weekly frequency', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 1); // Monday
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act & Assert
        final monday = DateTime(2024, 1, 8); // Next Monday
        final tuesday = DateTime(2024, 1, 9); // Tuesday
        
        expect(await service.isCheckinDay(monday), true);
        expect(await service.isCheckinDay(tuesday), false);
      });

      testWidgets('should return correct days for biweekly frequency', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.biweekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act & Assert
        final day14 = DateTime(2024, 1, 15); // 14 days later
        final day15 = DateTime(2024, 1, 16); // 15 days later
        
        expect(await service.isCheckinDay(day14), true);
        expect(await service.isCheckinDay(day15), false);
      });

      testWidgets('should return correct days for monthly frequency', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 15); // 15th of January
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.monthly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act & Assert
        final feb15 = DateTime(2024, 2, 15); // 15th of February
        final feb16 = DateTime(2024, 2, 16); // 16th of February
        
        expect(await service.isCheckinDay(feb15), true);
        expect(await service.isCheckinDay(feb16), false);
      });

      testWidgets('should handle monthly frequency with different month lengths', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 31); // 31st of January
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.monthly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act & Assert
        // February only has 29 days in 2024 (leap year), so should use last day
        final feb29 = DateTime(2024, 2, 29); // Last day of February
        final feb28 = DateTime(2024, 2, 28); // 28th of February
        
        expect(await service.isCheckinDay(feb29), true);
        expect(await service.isCheckinDay(feb28), false);
      });

      testWidgets('should return false for dates before start date', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 15);
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.daily);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act
        final beforeStartDate = DateTime(2024, 1, 10);
        final result = await service.isCheckinDay(beforeStartDate);

        // Assert
        expect(result, false);
      });
    });

    group('getCheckinDaysForMonth', () {
      testWidgets('should return correct check-in days for a month', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 1); // Monday
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act
        final result = await service.getCheckinDaysForMonth(DateTime(2024, 1, 15));

        // Assert
        expect(result, isA<Map<DateTime, bool>>());
        expect(result[DateTime(2024, 1, 1)], true);  // Monday
        expect(result[DateTime(2024, 1, 8)], true);  // Monday
        expect(result[DateTime(2024, 1, 15)], true); // Monday
        expect(result[DateTime(2024, 1, 22)], true); // Monday
        expect(result[DateTime(2024, 1, 29)], true); // Monday
        expect(result[DateTime(2024, 1, 2)], false); // Tuesday
        expect(result[DateTime(2024, 1, 3)], false); // Wednesday
      });

      testWidgets('should handle empty weight history', (WidgetTester tester) async {
        // Arrange
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => []);

        // Act
        final result = await service.getCheckinDaysForMonth(DateTime(2024, 1, 15));

        // Assert
        expect(result, isA<Map<DateTime, bool>>());
        // Should still return a map with all days, but with default behavior
        expect(result.isNotEmpty, true);
      });
    });

    group('getCheckinDaysInRange', () {
      testWidgets('should return correct check-in days in date range', (WidgetTester tester) async {
        // Arrange
        final startDate = DateTime(2024, 1, 1); // Monday
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act
        final result = await service.getCheckinDaysInRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        // Assert
        expect(result, isA<List<DateTime>>());
        expect(result.length, 5); // 5 Mondays in January 2024
        expect(result.contains(DateTime(2024, 1, 1)), true);
        expect(result.contains(DateTime(2024, 1, 8)), true);
        expect(result.contains(DateTime(2024, 1, 15)), true);
        expect(result.contains(DateTime(2024, 1, 22)), true);
        expect(result.contains(DateTime(2024, 1, 29)), true);
      });
    });

    group('isTodayCheckinDay', () {
      testWidgets('should check if today is a check-in day', (WidgetTester tester) async {
        // Arrange
        final today = DateTime.now();
        final startDate = DateTime(today.year, today.month, today.day - 7); // Week ago, same day
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);
        when(mockUsecase.getAllWeightHistory()).thenAnswer((_) async => [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: startDate,
          ),
        ]);

        // Act
        final result = await service.isTodayCheckinDay();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('delegation methods', () {
      testWidgets('should delegate getCheckinFrequency to usecase', (WidgetTester tester) async {
        // Arrange
        when(mockUsecase.getCheckinFrequency()).thenAnswer((_) async => CheckinFrequency.weekly);

        // Act
        final result = await service.getCheckinFrequency();

        // Assert
        expect(result, CheckinFrequency.weekly);
        verify(mockUsecase.getCheckinFrequency()).called(1);
      });

      testWidgets('should delegate setCheckinFrequency to usecase', (WidgetTester tester) async {
        // Arrange
        when(mockUsecase.setCheckinFrequency(any)).thenAnswer((_) async {});

        // Act
        await service.setCheckinFrequency(CheckinFrequency.daily);

        // Assert
        verify(mockUsecase.setCheckinFrequency(CheckinFrequency.daily)).called(1);
      });

      testWidgets('should delegate getNextCheckinDate to usecase', (WidgetTester tester) async {
        // Arrange
        final nextDate = DateTime(2024, 1, 15);
        when(mockUsecase.getNextCheckinDate()).thenAnswer((_) async => nextDate);

        // Act
        final result = await service.getNextCheckinDate();

        // Assert
        expect(result, nextDate);
        verify(mockUsecase.getNextCheckinDate()).called(1);
      });
    });
  });
}