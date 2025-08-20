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
    double? servingWeightGrams,
    bool? isEstimatedServingWeight,
  }) async {
    final targetDate = date ?? DateTime.now();
    
    _log.info('Adding food entry: $foodName ($amount $unit) for ${targetDate.toString().split(' ')[0]}');
    _log.info('Nutrition: $calories cal, ${protein}g protein, ${carbs}g carbs, ${fat}g fat');
    
    // Normalize units and amounts
    // IntakeEntity.amount must be in base units (g/ml) to work with energyPerUnit (per g/ml)
    // If unit == serving, require servingWeightGrams to convert to grams
    String normalizedUnit = unit.toLowerCase();
    double normalizedAmount = amount; // in g/ml after normalization

    // Calculate per-100g/ml nutriments depending on unit
    // Incoming values (calories/protein/carbs/fat) are per ONE unit specified by `unit`
    double energyPer100;
    double proteinPer100;
    double carbsPer100;
    double fatPer100;

    if (normalizedUnit == 'serving' || normalizedUnit == 'portion') {
      if (servingWeightGrams == null || servingWeightGrams <= 0) {
        _log.warning('Missing servingWeightGrams for unit=serving. Aborting add.');
        throw ArgumentError('servingWeightGrams is required when unit is "serving"');
      }
      // Convert number of servings to grams
      normalizedUnit = 'g';
      normalizedAmount = amount * servingWeightGrams;

      // Convert per-serving to per-100g
      energyPer100 = (calories / servingWeightGrams) * 100.0;
      proteinPer100 = (protein / servingWeightGrams) * 100.0;
      carbsPer100 = (carbs / servingWeightGrams) * 100.0;
      fatPer100 = (fat / servingWeightGrams) * 100.0;
    } else if (normalizedUnit == 'g' || normalizedUnit == 'gram' || normalizedUnit == 'grams') {
      normalizedUnit = 'g';
      normalizedAmount = amount;
      energyPer100 = calories * 100.0;
      proteinPer100 = protein * 100.0;
      carbsPer100 = carbs * 100.0;
      fatPer100 = fat * 100.0;
    } else if (normalizedUnit == 'ml') {
      normalizedUnit = 'ml';
      normalizedAmount = amount;
      energyPer100 = calories * 100.0;
      proteinPer100 = protein * 100.0;
      carbsPer100 = carbs * 100.0;
      fatPer100 = fat * 100.0;
    } else {
      // Unknown unit: default assume grams to avoid crashes, and log
      _log.warning('Unknown unit "$unit". Assuming grams.');
      normalizedUnit = 'g';
      normalizedAmount = amount;
      energyPer100 = calories * 100.0;
      proteinPer100 = protein * 100.0;
      carbsPer100 = carbs * 100.0;
      fatPer100 = fat * 100.0;
    }

    // Create meal entity with normalized nutriments
    final mealEntity = MealEntity(
      code: IdGenerator.getUniqueID(),
      name: foodName,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: normalizedAmount.toString(),
      mealUnit: normalizedUnit,
      // For serving inputs, we store the serving weight for UI reference; otherwise leave null
      servingQuantity: (unit.toLowerCase() == 'serving' || unit.toLowerCase() == 'portion')
          ? servingWeightGrams
          : null,
      servingUnit: (unit.toLowerCase() == 'serving' || unit.toLowerCase() == 'portion')
          ? 'g'
          : normalizedUnit,
      servingSize: (unit.toLowerCase() == 'serving' || unit.toLowerCase() == 'portion')
          ? '${servingWeightGrams?.toStringAsFixed(0) ?? '?'} g${(isEstimatedServingWeight ?? false) ? ' (est.)' : ''}'
          : '$normalizedAmount $normalizedUnit',
      nutriments: MealNutrimentsEntity(
        energyKcal100: energyPer100,
        proteins100: proteinPer100,
        carbohydrates100: carbsPer100,
        fat100: fatPer100,
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
      unit: normalizedUnit,
      amount: normalizedAmount,
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
        calories: (entry['calories'] as num).toDouble(),
        protein: (entry['protein'] as num).toDouble(),
        carbs: (entry['carbs'] as num).toDouble(),
        fat: (entry['fat'] as num).toDouble(),
        amount: (entry['amount'] as num).toDouble(),
        unit: entry['unit'] as String,
        mealType: entry['mealType'] as String,
        date: targetDate,
        servingWeightGrams: (entry['servingWeightGrams'] as num?)?.toDouble(),
        isEstimatedServingWeight: entry['isEstimated'] as bool?,
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

    // Note: Calories and macros are now calculated dynamically from food entries
    // No need to update tracked day calories/macros since they're calculated on-demand
  }
} 