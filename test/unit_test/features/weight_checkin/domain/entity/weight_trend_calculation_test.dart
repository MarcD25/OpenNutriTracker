import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/data/data_source/weight_checkin_data_source.dart';
import 'package:opennutritracker/features/weight_checkin/data/dbo/weight_entry_dbo.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_notification_service.dart';

@GenerateMocks([WeightCheckinDataSource, WeightCheckinNotificationService])
import 'weight_trend_calculation_test.mocks.dart';

void main() {
  late WeightCheckinUsecase usecase;
  late MockWeightCheckinDataSource mockDataSource;
  late MockWeightCheckinNotificationService mockNotificationService;

  setUp(() {
    mockDataSource = MockWeightCheckinDataSource();
    mockNotificationService = MockWeightCheckinNotificationService();
    usecase = WeightCheckinUsecase(mockDataSource, mockNotificationService);
  });

  group('WeightTrendCalculation', () {
    group('trend direction calculation', () {
      test('should calculate increasing trend correctly', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
          ),
          WeightEntryEntity(
            id: '2',
            weightKG: 71.0,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          WeightEntryEntity(
            id: '3',
            weightKG: 72.0,
            timestamp: DateTime.now(),
          ),
        ];

        // Mock the data source to return our test entries
        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(14);

        expect(trend.trendDirection, WeightTrendDirection.increasing);
        expect(trend.totalChange, 2.0);
        expect(trend.dataPoints, 3);
        expect(trend.averageWeeklyChange, closeTo(1.0, 0.1)); // ~1kg per week
      });

      test('should calculate decreasing trend correctly', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 75.0,
            timestamp: DateTime.now().subtract(const Duration(days: 21)),
          ),
          WeightEntryEntity(
            id: '2',
            weightKG: 73.0,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
          ),
          WeightEntryEntity(
            id: '3',
            weightKG: 71.0,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          WeightEntryEntity(
            id: '4',
            weightKG: 69.0,
            timestamp: DateTime.now(),
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(21);

        expect(trend.trendDirection, WeightTrendDirection.decreasing);
        expect(trend.totalChange, -6.0);
        expect(trend.dataPoints, 4);
        expect(trend.averageWeeklyChange, closeTo(-2.0, 0.1)); // ~2kg loss per week
      });

      test('should calculate stable trend for minimal changes', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
          ),
          WeightEntryEntity(
            id: '2',
            weightKG: 70.05,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          WeightEntryEntity(
            id: '3',
            weightKG: 69.95,
            timestamp: DateTime.now(),
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(14);

        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.totalChange.abs(), lessThan(0.1));
        expect(trend.averageWeeklyChange.abs(), lessThan(0.1));
      });
    });

    group('confidence level calculation', () {
      test('should assign high confidence for many consistent data points', () async {
        final entries = List.generate(10, (index) => WeightEntryEntity(
          id: index.toString(),
          weightKG: 70.0 - (index * 0.2), // Consistent 0.2kg decrease
          timestamp: DateTime.now().subtract(Duration(days: index * 3)),
        ));

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(30);

        expect(trend.confidence, WeightTrendConfidence.high);
        expect(trend.dataPoints, 10);
        expect(trend.trendDirection, WeightTrendDirection.decreasing);
      });

      test('should assign medium confidence for moderate data points', () async {
        final entries = List.generate(5, (index) => WeightEntryEntity(
          id: index.toString(),
          weightKG: 70.0 + (index * 0.3),
          timestamp: DateTime.now().subtract(Duration(days: index * 4)),
        ));

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(20);

        expect(trend.confidence, WeightTrendConfidence.medium);
        expect(trend.dataPoints, 5);
      });

      test('should assign low confidence for few data points', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          WeightEntryEntity(
            id: '2',
            weightKG: 71.0,
            timestamp: DateTime.now(),
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(7);

        expect(trend.confidence, WeightTrendConfidence.low);
        expect(trend.dataPoints, 2);
      });
    });

    group('edge cases', () {
      test('should handle single data point', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 70.0,
            timestamp: DateTime.now(),
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(7);

        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.totalChange, 0.0);
        expect(trend.averageWeeklyChange, 0.0);
        expect(trend.confidence, WeightTrendConfidence.low);
      });

      test('should handle empty data', () async {
        final entries = <WeightEntryEntity>[];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(7);

        expect(trend.trendDirection, WeightTrendDirection.stable);
        expect(trend.totalChange, 0.0);
        expect(trend.averageWeeklyChange, 0.0);
        expect(trend.confidence, WeightTrendConfidence.low);
        expect(trend.dataPoints, 0);
      });

      test('should handle extreme weight values', () async {
        final entries = [
          WeightEntryEntity(
            id: '1',
            weightKG: 300.0,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          WeightEntryEntity(
            id: '2',
            weightKG: 20.0,
            timestamp: DateTime.now(),
          ),
        ];

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final trend = await usecase.calculateWeightTrend(7);

        expect(trend.totalChange, -280.0);
        expect(trend.trendDirection, WeightTrendDirection.decreasing);
        // Confidence should be low due to extreme change
        expect(trend.confidence, WeightTrendConfidence.low);
      });
    });

    group('validation and utility methods', () {
      test('should validate weight input correctly', () {
        // Valid weights in kg
        expect(usecase.isValidWeight(70.0, isKilograms: true), true);
        expect(usecase.isValidWeight(50.0, isKilograms: true), true);
        expect(usecase.isValidWeight(150.0, isKilograms: true), true);
        
        // Invalid weights in kg
        expect(usecase.isValidWeight(10.0, isKilograms: true), false);
        expect(usecase.isValidWeight(400.0, isKilograms: true), false);
        
        // Valid weights in lbs
        expect(usecase.isValidWeight(150.0, isKilograms: false), true);
        expect(usecase.isValidWeight(200.0, isKilograms: false), true);
        
        // Invalid weights in lbs
        expect(usecase.isValidWeight(30.0, isKilograms: false), false);
        expect(usecase.isValidWeight(800.0, isKilograms: false), false);
      });

      test('should convert weight between units correctly', () {
        // kg to lbs
        final kgToLbs = usecase.convertWeight(70.0, fromKgToLbs: true);
        expect(kgToLbs, closeTo(154.32, 0.1));
        
        // lbs to kg
        final lbsToKg = usecase.convertWeight(154.32, fromKgToLbs: false);
        expect(lbsToKg, closeTo(70.0, 0.1));
      });

      test('should calculate BMI correctly', () {
        final bmi = usecase.calculateBMI(70.0, 175.0);
        expect(bmi, closeTo(22.86, 0.1));
      });

      test('should categorize BMI correctly', () {
        expect(usecase.getBMICategory(17.0), BMICategory.underweight);
        expect(usecase.getBMICategory(22.0), BMICategory.normal);
        expect(usecase.getBMICategory(27.0), BMICategory.overweight);
        expect(usecase.getBMICategory(32.0), BMICategory.obese);
      });
    });

    group('performance tests', () {
      test('should handle large datasets efficiently', () async {
        // Create 100 data points
        final entries = List.generate(100, (index) => WeightEntryEntity(
          id: index.toString(),
          weightKG: 70.0 + (index * 0.1), // Gradual increase
          timestamp: DateTime.now().subtract(Duration(days: index)),
        ));

        when(mockDataSource.getWeightHistory(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        )).thenAnswer((_) async => entries.map((e) => WeightEntryDBO.fromWeightEntryEntity(e)).toList());

        final stopwatch = Stopwatch()..start();
        final trend = await usecase.calculateWeightTrend(100);
        stopwatch.stop();

        expect(trend.dataPoints, 100);
        expect(trend.trendDirection, WeightTrendDirection.increasing);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });
    });
  });
}