import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:logging/logging.dart';

class AIFoodEntryUsecase {
  final AddIntakeUsecase _addIntakeUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final Logger _log = Logger('AIFoodEntryUsecase');

  AIFoodEntryUsecase(
    this._addIntakeUsecase,
    this._addTrackedDayUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
  );

  /// Adds a food entry to the user's diary for a specific date
  /// 
  /// [foodName] - Name of the food item
  /// [calories] - Calories per unit (e.g., per 100g)
  /// [protein] - Protein in grams per unit
  /// [carbs] - Carbohydrates in grams per unit  
  /// [fat] - Fat in grams per unit
  /// [amount] - Amount consumed
  /// [unit] - Unit of measurement (g, ml, serving, etc.)
  /// [mealType] - Type of meal (breakfast, lunch, dinner, snack)
  /// [date] - Date to add the entry for (defaults to today)
  Future<void> addFoodEntry({
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double amount,
    required String unit,
    required String mealType,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    
    _log.info('Adding food entry: $foodName ($amount $unit) for ${targetDate.toString().split(' ')[0]}');
    _log.info('Nutrition: $calories cal, ${protein}g protein, ${carbs}g carbs, ${fat}g fat');
    
    // Create meal entity
    final mealEntity = MealEntity(
      code: IdGenerator.getUniqueID(),
      name: foodName,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: amount.toString(),
      mealUnit: unit,
      servingQuantity: amount,
      servingUnit: unit,
      servingSize: '$amount $unit',
      nutriments: MealNutrimentsEntity(
        energyKcal100: calories * 100, // Convert to per 100g
        proteins100: protein * 100,
        carbohydrates100: carbs * 100,
        fat100: fat * 100,
        sugars100: 0,
        saturatedFat100: 0,
        fiber100: 0,
      ),
      source: MealSourceEntity.custom,
    );

    // Determine intake type
    final intakeType = _getIntakeTypeFromString(mealType);

    // Create intake entity
    final intakeEntity = IntakeEntity(
      id: IdGenerator.getUniqueID(),
      unit: unit,
      amount: amount,
      type: intakeType,
      meal: mealEntity,
      dateTime: targetDate,
    );

    // Add the intake
    await _addIntakeUsecase.addIntake(intakeEntity);
    _log.info('Successfully added food entry to diary');

    // Update tracked day
    await _updateTrackedDay(intakeEntity, targetDate);
    _log.info('Updated tracked day with new intake');
  }

  /// Adds multiple food entries for a specific date
  Future<void> addMultipleFoodEntries({
    required List<Map<String, dynamic>> foodEntries,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    
    for (final entry in foodEntries) {
      await addFoodEntry(
        foodName: entry['name'] as String,
        calories: entry['calories'] as double,
        protein: entry['protein'] as double,
        carbs: entry['carbs'] as double,
        fat: entry['fat'] as double,
        amount: entry['amount'] as double,
        unit: entry['unit'] as String,
        mealType: entry['mealType'] as String,
        date: targetDate,
      );
    }
  }

  /// Converts meal type string to IntakeTypeEntity
  IntakeTypeEntity _getIntakeTypeFromString(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return IntakeTypeEntity.breakfast;
      case 'lunch':
        return IntakeTypeEntity.lunch;
      case 'dinner':
        return IntakeTypeEntity.dinner;
      case 'snack':
        return IntakeTypeEntity.snack;
      default:
        return IntakeTypeEntity.snack; // Default to snack
    }
  }

  /// Updates tracked day with new intake
  Future<void> _updateTrackedDay(IntakeEntity intakeEntity, DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
      final totalCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal = await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      await _addTrackedDayUsecase.addNewTrackedDay(
        day, 
        totalKcalGoal, 
        totalCarbsGoal, 
        totalFatGoal, 
        totalProteinGoal
      );
    }

    _addTrackedDayUsecase.addDayCaloriesTracked(day, intakeEntity.totalKcal);
    _addTrackedDayUsecase.addDayMacrosTracked(
      day,
      carbsTracked: intakeEntity.totalCarbsGram,
      fatTracked: intakeEntity.totalFatsGram,
      proteinTracked: intakeEntity.totalProteinsGram,
    );
  }
} 