import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/data/repository/user_activity_repository.dart';
import 'package:opennutritracker/core/data/repository/user_repository.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';
import 'package:opennutritracker/core/domain/entity/config_entity.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/calorie_recommendation_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';

import 'get_kcal_goal_usecase_enhanced_test.mocks.dart';

@GenerateMocks([UserRepository, ConfigRepository, UserActivityRepository])
void main() {
  group('GetKcalGoalUsecase Enhanced Methods', () {
    late GetKcalGoalUsecase usecase;
    late MockUserRepository mockUserRepository;
    late MockConfigRepository mockConfigRepository;
    late MockUserActivityRepository mockUserActivityRepository;
    late UserEntity testUser;
    late ConfigEntity testConfig;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockConfigRepository = MockConfigRepository();
      mockUserActivityRepository = MockUserActivityRepository();
      usecase = GetKcalGoalUsecase(
          mockUserRepository, mockConfigRepository, mockUserActivityRepository);

      testUser = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 175,
        weightKG: 70,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.sedentary,
      );

      testConfig = ConfigEntity(
        true, // hasAcceptedDisclaimer
        true, // hasAcceptedPolicy
        false, // hasAcceptedSendAnonymousData
        AppThemeEntity.light, // appTheme
        userKcalAdjustment: 0,
      );
    });

    test('getEnhancedKcalGoal should return BMI-adjusted calorie goal', () async {
      // Arrange
      when(mockUserRepository.getUserData()).thenAnswer((_) async => testUser);
      when(mockConfigRepository.getConfig()).thenAnswer((_) async => testConfig);
      when(mockUserActivityRepository.getAllUserActivityByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.getEnhancedKcalGoal();

      // Assert
      expect(result, isA<double>());
      expect(result, greaterThan(0));
      verify(mockUserRepository.getUserData()).called(1);
      verify(mockConfigRepository.getConfig()).called(1);
    });

    test('getEnhancedKcalGoal should include exercise calories', () async {
      // Arrange
      final exerciseActivity = UserActivityEntity(
        '1', // id
        30.0, // duration
        300.0, // burnedKcal
        DateTime.now(), // date
        PhysicalActivityEntity(
          '12020', // code
          'Running', // specificActivity
          'Running, general', // description
          10.0, // mets
          ['running'], // tags
          PhysicalActivityTypeEntity.running, // type
        ),
      );

      when(mockUserRepository.getUserData()).thenAnswer((_) async => testUser);
      when(mockConfigRepository.getConfig()).thenAnswer((_) async => testConfig);
      when(mockUserActivityRepository.getAllUserActivityByDate(any))
          .thenAnswer((_) async => [exerciseActivity]);

      // Act
      final resultWithoutExercise = await usecase.getEnhancedKcalGoal(totalKcalActivitiesParam: 0);
      final resultWithExercise = await usecase.getEnhancedKcalGoal(totalKcalActivitiesParam: 300);

      // Assert
      expect(resultWithExercise, greaterThan(resultWithoutExercise));
      expect(resultWithExercise - resultWithoutExercise, equals(300));
    });

    test('getCalorieRecommendation should return complete recommendation', () async {
      // Arrange
      when(mockUserRepository.getUserData()).thenAnswer((_) async => testUser);
      when(mockUserActivityRepository.getAllUserActivityByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.getCalorieRecommendation();

      // Assert
      expect(result, isA<CalorieRecommendation>());
      expect(result.baseTDEE, greaterThan(0));
      expect(result.bmiCategory, equals(BMICategory.normal));
      expect(result.recommendations, isNotEmpty);
      verify(mockUserRepository.getUserData()).called(1);
    });

    test('getNetCaloriesRemaining should calculate correctly', () async {
      // Arrange
      when(mockUserRepository.getUserData()).thenAnswer((_) async => testUser);
      when(mockUserActivityRepository.getAllUserActivityByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.getNetCaloriesRemaining(foodCaloriesConsumed: 1500);

      // Assert
      expect(result, isA<double>());
      // Should be positive since 1500 calories is likely less than TDEE
      expect(result, greaterThan(0));
    });

    test('legacy getKcalGoal should still work for backward compatibility', () async {
      // Arrange
      when(mockUserRepository.getUserData()).thenAnswer((_) async => testUser);
      when(mockConfigRepository.getConfig()).thenAnswer((_) async => testConfig);
      when(mockUserActivityRepository.getAllUserActivityByDate(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.getKcalGoal();

      // Assert
      expect(result, isA<double>());
      expect(result, greaterThan(0));
      verify(mockUserRepository.getUserData()).called(1);
      verify(mockConfigRepository.getConfig()).called(1);
    });
  });
}