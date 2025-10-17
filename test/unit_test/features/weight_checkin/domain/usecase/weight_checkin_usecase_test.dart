import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:opennutritracker/features/weight_checkin/data/data_source/weight_checkin_data_source.dart';
import 'package:opennutritracker/features/weight_checkin/data/dbo/weight_entry_dbo.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_notification_service.dart';

@GenerateMocks([WeightCheckinDataSource, WeightCheckinNotificationService])
import 'weight_checkin_usecase_test.mocks.dart';

void main() {
  late WeightCheckinUsecase usecase;
  late MockWeightCheckinDataSource mockDataSource;
  late MockWeightCheckinNotificationService mockNotificationService;

  setUp(() {
    mockDataSource = MockWeightCheckinDataSource();
    mockNotificationService = MockWeightCheckinNotificationService();
    usecase = WeightCheckinUsecase(mockDataSource, mockNotificationService);
  });

  group('WeightCheckinUsecase', () {
    group('recordWeightEntry', () {
      test('should save weight entry with correct data', () async {
        // Arrange
        const weight = 70.5;
        const notes = 'Test notes';

        when(mockDataSource.saveWeightEntry(any))
            .thenAnswer((_) async => {});
        when(mockDataSource.updateLastCheckinDate(any))
            .thenAnswer((_) async => {});

        // Act
        await usecase.recordWeightEntry(weight, notes: notes);

        // Assert
        verify(mockDataSource.saveWeightEntry(any)).called(1);
        verify(mockDataSource.updateLastCheckinDate(any)).called(1);
      });
    });

    group('calculateWeightTrend', () {
      test('should return stable trend for insufficient data', () async {
        // Arrange
        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => []);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.confidence, WeightTrendConfidence.low);
        expect(trend.dataPoints, 0);
      });

      test('should calculate increasing trend correctly', () async {
        // Arrange
        final now = DateTime.now();
        final entries = [
          WeightEntryDBO(
            id: '1',
            weightKG: 70.0,
            timestamp: now.subtract(const Duration(days: 14)),
          ),
          WeightEntryDBO(
            id: '2',
            weightKG: 71.0,
            timestamp: now.subtract(const Duration(days: 7)),
          ),
          WeightEntryDBO(
            id: '3',
            weightKG: 72.0,
            timestamp: now,
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.increasing);
        expect(trend.totalChange, 2.0);
        expect(trend.dataPoints, 3);
      });

      test('should calculate decreasing trend correctly', () async {
        // Arrange
        final now = DateTime.now();
        final entries = [
          WeightEntryDBO(
            id: '1',
            weightKG: 75.0,
            timestamp: now.subtract(const Duration(days: 14)),
          ),
          WeightEntryDBO(
            id: '2',
            weightKG: 73.0,
            timestamp: now.subtract(const Duration(days: 7)),
          ),
          WeightEntryDBO(
            id: '3',
            weightKG: 71.0,
            timestamp: now,
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.decreasing);
        expect(trend.totalChange, -4.0);
        expect(trend.dataPoints, 3);
      });
    });

    group('weight validation', () {
      test('should validate weight in kg correctly', () {
        // Valid weights
        expect(usecase.isValidWeight(70.0, isKilograms: true), true);
        expect(usecase.isValidWeight(20.0, isKilograms: true), true);
        expect(usecase.isValidWeight(300.0, isKilograms: true), true);

        // Invalid weights
        expect(usecase.isValidWeight(19.9, isKilograms: true), false);
        expect(usecase.isValidWeight(300.1, isKilograms: true), false);
      });

      test('should validate weight in lbs correctly', () {
        // Valid weights
        expect(usecase.isValidWeight(154.0, isKilograms: false), true);
        expect(usecase.isValidWeight(44.0, isKilograms: false), true);
        expect(usecase.isValidWeight(661.0, isKilograms: false), true);

        // Invalid weights
        expect(usecase.isValidWeight(43.9, isKilograms: false), false);
        expect(usecase.isValidWeight(661.1, isKilograms: false), false);
      });
    });

    group('weight conversion', () {
      test('should convert kg to lbs correctly', () {
        const weightKg = 70.0;
        final weightLbs = usecase.convertWeight(weightKg, fromKgToLbs: true);
        expect(weightLbs, closeTo(154.32, 0.01));
      });

      test('should convert lbs to kg correctly', () {
        const weightLbs = 154.32;
        final weightKg = usecase.convertWeight(weightLbs, fromKgToLbs: false);
        expect(weightKg, closeTo(70.0, 0.01));
      });
    });

    group('BMI calculation', () {
      test('should calculate BMI correctly', () {
        const weightKg = 70.0;
        const heightCm = 175.0;
        final bmi = usecase.calculateBMI(weightKg, heightCm);
        expect(bmi, closeTo(22.86, 0.01));
      });

      test('should categorize BMI correctly', () {
        expect(usecase.getBMICategory(17.0), BMICategory.underweight);
        expect(usecase.getBMICategory(22.0), BMICategory.normal);
        expect(usecase.getBMICategory(27.0), BMICategory.overweight);
        expect(usecase.getBMICategory(32.0), BMICategory.obese);
      });
    });

    group('shouldShowCheckinReminder', () {
      test('should return true for first time user', () async {
        // Arrange
        when(mockDataSource.getNextCheckinDate())
            .thenAnswer((_) async => null);

        // Act
        final shouldShow = await usecase.shouldShowCheckinReminder();

        // Assert
        expect(shouldShow, true);
      });

      test('should return true when next checkin date has passed', () async {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        when(mockDataSource.getNextCheckinDate())
            .thenAnswer((_) async => pastDate);

        // Act
        final shouldShow = await usecase.shouldShowCheckinReminder();

        // Assert
        expect(shouldShow, true);
      });

      test('should return false when next checkin date is in future', () async {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 1));
        when(mockDataSource.getNextCheckinDate())
            .thenAnswer((_) async => futureDate);

        // Act
        final shouldShow = await usecase.shouldShowCheckinReminder();

        // Assert
        expect(shouldShow, false);
      });
    });

    group('weight trend calculation edge cases', () {
      test('should handle single data point correctly', () async {
        // Arrange
        final now = DateTime.now();
        final entries = [
          WeightEntryDBO(
            id: '1',
            weightKG: 70.0,
            timestamp: now,
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.confidence, WeightTrendConfidence.low);
        expect(trend.totalChange, 0.0);
        expect(trend.averageWeeklyChange, 0.0);
      });

      test('should calculate stable trend for minimal weight changes', () async {
        // Arrange
        final now = DateTime.now();
        final entries = [
          WeightEntryDBO(
            id: '1',
            weightKG: 70.0,
            timestamp: now.subtract(const Duration(days: 14)),
          ),
          WeightEntryDBO(
            id: '2',
            weightKG: 70.05,
            timestamp: now.subtract(const Duration(days: 7)),
          ),
          WeightEntryDBO(
            id: '3',
            weightKG: 69.95,
            timestamp: now,
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.totalChange.abs(), lessThan(0.1));
      });

      test('should calculate weekly change correctly for different time periods', () async {
        // Arrange
        final now = DateTime.now();
        final entries = [
          WeightEntryDBO(
            id: '1',
            weightKG: 70.0,
            timestamp: now.subtract(const Duration(days: 28)), // 4 weeks ago
          ),
          WeightEntryDBO(
            id: '2',
            weightKG: 68.0,
            timestamp: now, // 2kg loss over 4 weeks
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.trendDirection, WeightTrendDirection.decreasing);
        expect(trend.totalChange, -2.0);
        expect(trend.averageWeeklyChange, closeTo(-0.5, 0.1)); // 0.5kg per week
      });

      test('should determine confidence level based on data points', () async {
        // Arrange
        final now = DateTime.now();
        
        // Test with many data points (should be high confidence)
        final manyEntries = List.generate(10, (index) => WeightEntryDBO(
          id: index.toString(),
          weightKG: 70.0 - (index * 0.2), // Consistent decreasing trend
          timestamp: now.subtract(Duration(days: index * 3)),
        ));

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => manyEntries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.confidence, WeightTrendConfidence.high);
        expect(trend.dataPoints, 10);
      });

      test('should handle inconsistent weight data', () async {
        // Arrange
        final now = DateTime.now();
        final inconsistentEntries = [
          WeightEntryDBO(id: '1', weightKG: 70.0, timestamp: now.subtract(const Duration(days: 21))),
          WeightEntryDBO(id: '2', weightKG: 72.0, timestamp: now.subtract(const Duration(days: 18))),
          WeightEntryDBO(id: '3', weightKG: 69.0, timestamp: now.subtract(const Duration(days: 15))),
          WeightEntryDBO(id: '4', weightKG: 73.0, timestamp: now.subtract(const Duration(days: 12))),
          WeightEntryDBO(id: '5', weightKG: 68.0, timestamp: now.subtract(const Duration(days: 9))),
          WeightEntryDBO(id: '6', weightKG: 71.0, timestamp: now.subtract(const Duration(days: 6))),
          WeightEntryDBO(id: '7', weightKG: 69.5, timestamp: now.subtract(const Duration(days: 3))),
          WeightEntryDBO(id: '8', weightKG: 70.5, timestamp: now),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => inconsistentEntries);

        // Act
        final trend = await usecase.calculateWeightTrend(30);

        // Assert
        expect(trend.confidence, WeightTrendConfidence.medium); // Should not be high due to inconsistency
      });
    });

    group('weight validation edge cases', () {
      test('should validate boundary weight values correctly', () {
        // Test exact boundaries
        expect(usecase.isValidWeight(20.0, isKilograms: true), true);
        expect(usecase.isValidWeight(300.0, isKilograms: true), true);
        expect(usecase.isValidWeight(44.0, isKilograms: false), true);
        expect(usecase.isValidWeight(661.0, isKilograms: false), true);

        // Test just outside boundaries
        expect(usecase.isValidWeight(19.99, isKilograms: true), false);
        expect(usecase.isValidWeight(300.01, isKilograms: true), false);
        expect(usecase.isValidWeight(43.99, isKilograms: false), false);
        expect(usecase.isValidWeight(661.01, isKilograms: false), false);
      });

      test('should handle decimal weight values', () {
        expect(usecase.isValidWeight(70.5, isKilograms: true), true);
        expect(usecase.isValidWeight(155.3, isKilograms: false), true);
      });

      test('should handle zero and negative weights', () {
        expect(usecase.isValidWeight(0.0, isKilograms: true), false);
        expect(usecase.isValidWeight(-5.0, isKilograms: true), false);
        expect(usecase.isValidWeight(0.0, isKilograms: false), false);
        expect(usecase.isValidWeight(-10.0, isKilograms: false), false);
      });
    });

    group('weight conversion precision', () {
      test('should maintain precision in conversions', () {
        const testWeights = [50.0, 75.5, 100.25, 150.75];
        
        for (final weight in testWeights) {
          final toLbs = usecase.convertWeight(weight, fromKgToLbs: true);
          final backToKg = usecase.convertWeight(toLbs, fromKgToLbs: false);
          
          expect(backToKg, closeTo(weight, 0.01));
        }
      });

      test('should handle extreme weight values in conversion', () {
        const extremeWeights = [20.0, 300.0]; // Boundary values
        
        for (final weight in extremeWeights) {
          final toLbs = usecase.convertWeight(weight, fromKgToLbs: true);
          expect(toLbs, greaterThan(0));
          
          final backToKg = usecase.convertWeight(toLbs, fromKgToLbs: false);
          expect(backToKg, closeTo(weight, 0.01));
        }
      });
    });

    group('BMI calculation accuracy', () {
      test('should calculate BMI with correct formula', () {
        // Test known BMI calculations
        const testCases = [
          {'weight': 70.0, 'height': 175.0, 'expectedBMI': 22.86},
          {'weight': 80.0, 'height': 180.0, 'expectedBMI': 24.69},
          {'weight': 60.0, 'height': 165.0, 'expectedBMI': 22.04},
        ];

        for (final testCase in testCases) {
          final bmi = usecase.calculateBMI(
            testCase['weight']! as double,
            testCase['height']! as double,
          );
          expect(bmi, closeTo(testCase['expectedBMI']! as double, 0.01));
        }
      });

      test('should categorize BMI boundary values correctly', () {
        // Test exact boundary values
        expect(usecase.getBMICategory(18.49), BMICategory.underweight);
        expect(usecase.getBMICategory(18.5), BMICategory.normal);
        expect(usecase.getBMICategory(24.99), BMICategory.normal);
        expect(usecase.getBMICategory(25.0), BMICategory.overweight);
        expect(usecase.getBMICategory(29.99), BMICategory.overweight);
        expect(usecase.getBMICategory(30.0), BMICategory.obese);
      });
    });

    group('caching behavior', () {
      test('should provide cache statistics', () {
        final stats = usecase.getCacheStats();
        expect(stats, isA<String>());
      });

      test('should handle cache operations without errors', () {
        // These operations should not throw
        expect(() => usecase.getCacheStats(), returnsNormally);
      });
    });

    group('error handling', () {
      test('should handle data source errors gracefully in recordWeightEntry', () async {
        // Arrange
        when(mockDataSource.saveWeightEntry(any))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => usecase.recordWeightEntry(70.0),
          throwsException,
        );
      });

      test('should handle data source errors gracefully in getWeightHistory', () async {
        // Arrange
        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => usecase.getWeightHistory(30),
          throwsException,
        );
      });
    });
  });
}