import 'dart:async';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/function_call_entity.dart';
import 'package:opennutritracker/features/chat/domain/usecase/ai_food_entry_usecase.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_diary_data_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/bulk_intake_operations_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/met_calc.dart';
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';

class FunctionExecutionService {
  final AIFoodEntryUsecase _aiFoodEntryUsecase;
  final BulkIntakeOperationsUsecase _bulkIntakeOperationsUsecase;
  final ChatDiaryDataUsecase _chatDiaryDataUsecase;
  final Logger _log = Logger('FunctionExecutionService');
  final GetUserActivityUsecase _getUserActivityUsecase;
  final AddUserActivityUsecase _addUserActivityUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final GetPhysicalActivityUsecase _getPhysicalActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetUserUsecase _getUserUsecase;

  FunctionExecutionService(
    this._aiFoodEntryUsecase,
    this._bulkIntakeOperationsUsecase,
    this._chatDiaryDataUsecase,
    this._getUserActivityUsecase,
    this._addUserActivityUsecase,
    this._deleteUserActivityUsecase,
    this._getPhysicalActivityUsecase,
    this._addTrackedDayUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
    this._getUserUsecase,
  );

  /// Executes a function call in the background
  Future<FunctionCallResult> executeFunction(FunctionCallEntity functionCall) async {
    try {
      _log.info('Executing function: ${functionCall.function}');
      _log.fine('Parameters: ${functionCall.parameters}');

      switch (functionCall.function) {
        case 'add_food_entry':
          return await _executeAddFoodEntry(functionCall.parameters);
        case 'add_multiple_food_entries':
          return await _executeAddMultipleFoodEntries(functionCall.parameters);
        case 'get_diary_range':
          return await _executeGetDiaryRange(functionCall.parameters);
        case 'delete_all_entries_for_date':
          return await _executeDeleteAllEntriesForDate(functionCall.parameters);
        case 'delete_entries_by_meal_type':
          return await _executeDeleteEntriesByMealType(functionCall.parameters);
        case 'delete_entries_for_date_range':
          return await _executeDeleteEntriesForDateRange(functionCall.parameters);
        case 'update_multiple_entries':
          return await _executeUpdateMultipleEntries(functionCall.parameters);
        case 'get_diary_data':
          return await _executeGetDiaryData(functionCall.parameters);
        case 'get_progress_summary':
          return await _executeGetProgressSummary(functionCall.parameters);
        case 'add_activity':
          return await _executeAddActivity(functionCall.parameters);
        case 'delete_activity':
          return await _executeDeleteActivity(functionCall.parameters);
        case 'get_activities':
          return await _executeGetActivities(functionCall.parameters);
        default:
          return FunctionCallResult.error('Unknown function: ${functionCall.function}');
      }
    } catch (e) {
      _log.severe('Error executing function ${functionCall.function}: $e');
      return FunctionCallResult.error('Execution error: $e');
    }
  }

  Future<FunctionCallResult> _executeAddActivity(Map<String, dynamic> params) async {
    try {
      final name = params['activityName'] as String;
      final duration = _parseNumericParam(params['durationMinutes']);
      final dateStr = params['date'] as String? ?? 'today';
      final day = _parseDate(dateStr);
      if (day == null) return FunctionCallResult.error('Invalid date: $dateStr');

      // Find physical activity by name (simple contains match)
      final activities = await _getPhysicalActivityUsecase.getAllPhysicalActivities();
      final match = activities.firstWhere(
        (a) => (a.code.toLowerCase().contains(name.toLowerCase())),
        orElse: () => activities.first,
      );

      // Compute burned kcal using MET and user data
      final user = await _getUserUsecase.getUserData();
      final burnedKcal = METCalc.getTotalBurnedKcal(user, match, duration);
      final userActivity = UserActivityEntity(
          IdGenerator.getUniqueID(), duration, burnedKcal, day, match);
      await _addUserActivityUsecase.addUserActivity(userActivity);

      // Ensure tracked day exists and adjust goals similar to ActivityDetailBloc
      await _ensureTrackedDayExists(day);
      final carbsIncrease = MacroCalc.getTotalCarbsGoal(burnedKcal);
      final fatIncrease = MacroCalc.getTotalFatsGoal(burnedKcal);
      final proteinIncrease = MacroCalc.getTotalProteinsGoal(burnedKcal);
      await _addTrackedDayUsecase.increaseDayCalorieGoal(day, burnedKcal);
      await _addTrackedDayUsecase.increaseDayMacroGoals(day,
          carbsAmount: carbsIncrease,
          fatAmount: fatIncrease,
          proteinAmount: proteinIncrease);

      return FunctionCallResult.success({'message': 'Added activity', 'activityName': name, 'date': day.toString()});
    } catch (e) {
      _log.severe('Error adding activity: $e');
      return FunctionCallResult.error('Failed to add activity: $e');
    }
  }

  Future<void> _ensureTrackedDayExists(DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal(totalKcalActivitiesParam: 0);
      final totalCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal = await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);
      await _addTrackedDayUsecase.addNewTrackedDay(day, totalKcalGoal, totalCarbsGoal, totalFatGoal, totalProteinGoal);
    }
  }

  Future<FunctionCallResult> _executeDeleteActivity(Map<String, dynamic> params) async {
    try {
      final id = params['activityId'] as String?;
      if (id == null) return FunctionCallResult.error('activityId is required');
      // We need an entity to delete; in current repo, deletion uses entity
      final day = DateTime.now();
      final dummy = UserActivityEntity(id, 0, 0, day, activitiesPlaceholder());
      await _deleteUserActivityUsecase.deleteUserActivity(dummy);
      return FunctionCallResult.success({'message': 'Deleted activity', 'activityId': id});
    } catch (e) {
      _log.severe('Error deleting activity: $e');
      return FunctionCallResult.error('Failed to delete activity: $e');
    }
  }

  PhysicalActivityEntity activitiesPlaceholder() {
    return const PhysicalActivityEntity('unknown', 'unknown', 'unknown', 1.0, [], PhysicalActivityTypeEntity.sport);
  }

  Future<FunctionCallResult> _executeGetActivities(Map<String, dynamic> params) async {
    try {
      final dateStr = params['date'] as String?;
      if (dateStr == null) return FunctionCallResult.error('date is required');
      final day = _parseDate(dateStr);
      if (day == null) return FunctionCallResult.error('Invalid date: $dateStr');
      final activities = await _getUserActivityUsecase.getUserActivityByDay(day);
      final data = activities.map((a) => {
        'id': a.id,
        'name': a.physicalActivityEntity.code,
        'durationMinutes': a.duration,
        'burnedKcal': a.burnedKcal,
        'date': a.date.toString(),
      }).toList();
      return FunctionCallResult.success({'message': 'Retrieved activities', 'data': data});
    } catch (e) {
      _log.severe('Error getting activities: $e');
      return FunctionCallResult.error('Failed to get activities: $e');
    }
  }

  /// Executes multiple function calls sequentially
  Future<List<FunctionCallResult>> executeFunctionCalls(List<FunctionCallEntity> functionCalls) async {
    final results = <FunctionCallResult>[];
    
    for (final functionCall in functionCalls) {
      final result = await executeFunction(functionCall);
      results.add(result);
      
      // If a function fails, log it but continue with others
      if (!result.success) {
        _log.warning('Function ${functionCall.function} failed: ${result.error}');
      }
    }
    
    return results;
  }

  // Individual function implementations
  Future<FunctionCallResult> _executeAddFoodEntry(Map<String, dynamic> params) async {
    try {
      final foodName = params['foodName'] as String;
      // Backward compatible: accept calories or caloriesPerUnit
      final calories = _parseNumericParam(params['calories'] ?? params['caloriesPerUnit']);
      final protein = _parseNumericParam(params['protein']);
      final carbs = _parseNumericParam(params['carbs']);
      final fat = _parseNumericParam(params['fat']);
      final amount = _parseNumericParam(params['amount']);
      final unit = params['unit'] as String;
      final mealType = params['mealType'] as String;
      final dateString = params['date'] as String? ?? 'today';
      final servingWeightGrams = params['servingWeightGrams'] != null
          ? _parseNumericParam(params['servingWeightGrams'])
          : null;
      final isEstimatedServingWeight = params['isEstimated'] as bool?;

      final targetDate = _parseDate(dateString);
      if (targetDate == null) {
        return FunctionCallResult.error('Invalid date: $dateString');
      }

      await _aiFoodEntryUsecase.addFoodEntry(
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        amount: amount,
        unit: unit,
        mealType: mealType,
        date: targetDate,
        servingWeightGrams: servingWeightGrams,
        isEstimatedServingWeight: isEstimatedServingWeight,
      );

      _log.info('Successfully added food entry: $foodName');
      return FunctionCallResult.success({
        'message': 'Added $foodName to your diary',
        'foodName': foodName,
        'date': targetDate.toString(),
      });
    } catch (e) {
      _log.severe('Error adding food entry: $e');
      return FunctionCallResult.error('Failed to add food entry: $e');
    }
  }

  Future<FunctionCallResult> _executeAddMultipleFoodEntries(Map<String, dynamic> params) async {
    try {
      final entries = params['entries'] as List;
      final dateString = params['date'] as String? ?? 'today';
      
      final targetDate = _parseDate(dateString);
      if (targetDate == null) {
        return FunctionCallResult.error('Invalid date: $dateString');
      }

      final foodEntries = <Map<String, dynamic>>[];
      for (final entry in entries) {
        final entryMap = entry as Map<String, dynamic>;
        foodEntries.add({
          'name': entryMap['foodName'] as String,
          'calories': _parseNumericParam(entryMap['calories'] ?? entryMap['caloriesPerUnit']),
          'protein': _parseNumericParam(entryMap['protein']),
          'carbs': _parseNumericParam(entryMap['carbs']),
          'fat': _parseNumericParam(entryMap['fat']),
          'amount': _parseNumericParam(entryMap['amount']),
          'unit': entryMap['unit'] as String,
          'mealType': entryMap['mealType'] as String,
          'servingWeightGrams': entryMap['servingWeightGrams'] != null
              ? _parseNumericParam(entryMap['servingWeightGrams'])
              : null,
          'isEstimated': entryMap['isEstimated'] as bool?,
        });
      }

      await _aiFoodEntryUsecase.addMultipleFoodEntries(
        foodEntries: foodEntries,
        date: targetDate,
      );

      _log.info('Successfully added ${foodEntries.length} food entries');
      return FunctionCallResult.success({
        'message': 'Added ${foodEntries.length} food entries to your diary',
        'count': foodEntries.length,
        'date': targetDate.toString(),
      });
    } catch (e) {
      _log.severe('Error adding multiple food entries: $e');
      return FunctionCallResult.error('Failed to add food entries: $e');
    }
  }

  Future<FunctionCallResult> _executeGetDiaryRange(Map<String, dynamic> params) async {
    try {
      final startDateStr = params['startDate'] as String?;
      final endDateStr = params['endDate'] as String?;
      if (startDateStr == null || endDateStr == null) {
        return FunctionCallResult.error('startDate and endDate are required');
      }
      final start = _parseDate(startDateStr);
      final end = _parseDate(endDateStr);
      if (start == null || end == null) {
        return FunctionCallResult.error('Invalid dates. Use YYYY-MM-DD');
      }
      if (end.isBefore(start)) {
        return FunctionCallResult.error('endDate must be on or after startDate');
      }

      final List<Map<String, dynamic>> days = [];
      DateTime cursor = DateTime(start.year, start.month, start.day);
      final DateTime endDay = DateTime(end.year, end.month, end.day);
      while (!cursor.isAfter(endDay)) {
        final entries = await _chatDiaryDataUsecase.getFoodEntriesForDate(cursor);
        final foodEntries = entries.map((e) => {
          'name': e.meal.name,
          'date': e.dateTime.toString().split(' ')[0],
          'calories': e.totalKcal,
          'mealType': e.type.toString().split('.').last,
          'amount': e.amount,
          'unit': e.unit,
        }).toList();
        final totalCalories = foodEntries.fold<double>(0.0, (sum, fe) => sum + (fe['calories'] as double));
        days.add({
          'date': cursor.toString().split(' ')[0],
          'entries': foodEntries,
          'totalCalories': totalCalories,
        });
        cursor = cursor.add(const Duration(days: 1));
      }

      return FunctionCallResult.success({
        'message': 'Retrieved diary data for range',
        'data': {
          'days': days,
          'startDate': start.toString(),
          'endDate': end.toString(),
        }
      });
    } catch (e) {
      _log.severe('Error in get_diary_range: $e');
      return FunctionCallResult.error('Failed to get diary range: $e');
    }
  }

  Future<FunctionCallResult> _executeDeleteAllEntriesForDate(Map<String, dynamic> params) async {
    try {
      final dateString = params['date'] as String;
      final targetDate = _parseDate(dateString);
      
      if (targetDate == null) {
        return FunctionCallResult.error('Invalid date: $dateString');
      }

      await _bulkIntakeOperationsUsecase.deleteAllIntakesForDate(targetDate);

      _log.info('Successfully deleted all entries for date: ${targetDate.toString().split(' ')[0]}');
      return FunctionCallResult.success({
        'message': 'Deleted all entries for ${targetDate.toString().split(' ')[0]}',
        'date': targetDate.toString(),
      });
    } catch (e) {
      _log.severe('Error deleting all entries for date: $e');
      return FunctionCallResult.error('Failed to delete entries: $e');
    }
  }

  Future<FunctionCallResult> _executeDeleteEntriesByMealType(Map<String, dynamic> params) async {
    try {
      final mealType = params['mealType'] as String;
      final dateString = params['date'] as String;
      final targetDate = _parseDate(dateString);
      
      if (targetDate == null) {
        return FunctionCallResult.error('Invalid date: $dateString');
      }

      final intakeType = _getIntakeTypeFromString(mealType);
      await _bulkIntakeOperationsUsecase.deleteIntakesForDateAndType(intakeType, targetDate);

      _log.info('Successfully deleted $mealType entries for date: ${targetDate.toString().split(' ')[0]}');
      return FunctionCallResult.success({
        'message': 'Deleted all $mealType entries for ${targetDate.toString().split(' ')[0]}',
        'mealType': mealType,
        'date': targetDate.toString(),
      });
    } catch (e) {
      _log.severe('Error deleting entries by meal type: $e');
      return FunctionCallResult.error('Failed to delete entries: $e');
    }
  }

  Future<FunctionCallResult> _executeDeleteEntriesForDateRange(Map<String, dynamic> params) async {
    try {
      final startDateString = params['startDate'] as String;
      final endDateString = params['endDate'] as String;
      
      final startDate = _parseDate(startDateString);
      final endDate = _parseDate(endDateString);
      
      if (startDate == null || endDate == null) {
        return FunctionCallResult.error('Invalid date range: $startDateString to $endDateString');
      }

      await _bulkIntakeOperationsUsecase.deleteAllIntakesForDateRange(startDate, endDate);

      _log.info('Successfully deleted entries for date range: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}');
      return FunctionCallResult.success({
        'message': 'Deleted all entries from ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}',
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
      });
    } catch (e) {
      _log.severe('Error deleting entries for date range: $e');
      return FunctionCallResult.error('Failed to delete entries: $e');
    }
  }

  Future<FunctionCallResult> _executeUpdateMultipleEntries(Map<String, dynamic> params) async {
    try {
      final intakeIds = (params['intakeIds'] as List).cast<String>();
      final fields = params['fields'] as Map<String, dynamic>;
      final dateString = params['date'] as String? ?? 'today';
      
      _log.info('Attempting to update entries with IDs: $intakeIds');
      
      // Check if we're dealing with placeholder IDs (generic or specific)
      final hasPlaceholderIds = intakeIds.any((id) => 
        id.startsWith('latest') || 
        id.startsWith('earliest') || 
        id.startsWith('first') ||
        id.startsWith('entry_id') ||
        id == 'all' ||
        id == 'all_entries'
      );
      
      if (hasPlaceholderIds) {
        _log.info('Detected placeholder IDs, will find actual intake IDs');
        
        // Get the target date
        final targetDate = _parseDate(dateString);
        if (targetDate == null) {
          return FunctionCallResult.error('Invalid date: $dateString');
        }
        
        // Get all entries for the target date
        final entries = await _chatDiaryDataUsecase.getFoodEntriesForDate(targetDate);
        
        if (entries.isEmpty) {
          return FunctionCallResult.error('No entries found for ${targetDate.toString().split(' ')[0]}');
        }
        
        // Sort entries by date (newest first for "latest", oldest first for "earliest")
        entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        
        // Map placeholder IDs to actual IDs
        final actualIds = <String>[];
        for (final placeholderId in intakeIds) {
          if (placeholderId == 'latest' || placeholderId == 'latest-1') {
            if (entries.isNotEmpty) {
              actualIds.add(entries.first.id);
            }
            if (placeholderId == 'latest-1' && entries.length > 1) {
              actualIds.add(entries[1].id);
            }
          } else if (placeholderId == 'earliest' || placeholderId == 'first') {
            if (entries.isNotEmpty) {
              actualIds.add(entries.last.id);
            }
          } else if (placeholderId.startsWith('entry_id') || placeholderId == 'all' || placeholderId == 'all_entries') {
            // For generic placeholder IDs, get all entries of the current meal type
            final currentMealType = _getCurrentMealTypeFromFields(fields);
            if (currentMealType != null) {
              final matchingEntries = entries.where((e) => e.type == currentMealType).toList();
              actualIds.addAll(matchingEntries.map((e) => e.id));
            } else {
              // If no specific meal type, get all entries
              actualIds.addAll(entries.map((e) => e.id));
            }
          }
        }
        
        if (actualIds.isEmpty) {
          return FunctionCallResult.error('Could not find entries to update');
        }
        
        _log.info('Found actual intake IDs: $actualIds');
        
        // Handle meal type conversion if present
        final updatedFields = Map<String, dynamic>.from(fields);
        if (updatedFields.containsKey('mealType')) {
          final mealType = updatedFields['mealType'] as String;
          final intakeType = _getIntakeTypeFromString(mealType);
          updatedFields['type'] = intakeType;
          updatedFields.remove('mealType');
          _log.info('Converted mealType "$mealType" to intake type: $intakeType');
        }
        
        // Update the entries with actual IDs
        await _bulkIntakeOperationsUsecase.updateMultipleIntakes(actualIds, updatedFields);
        
        _log.info('Successfully updated ${actualIds.length} entries');
        return FunctionCallResult.success({
          'message': 'Updated ${actualIds.length} entries',
          'count': actualIds.length,
          'fields': updatedFields,
        });
      } else {
        // Handle meal type conversion if present
        final updatedFields = Map<String, dynamic>.from(fields);
        if (updatedFields.containsKey('mealType')) {
          final mealType = updatedFields['mealType'] as String;
          final intakeType = _getIntakeTypeFromString(mealType);
          updatedFields['type'] = intakeType;
          updatedFields.remove('mealType');
          _log.info('Converted mealType "$mealType" to intake type: $intakeType');
        }
        
        // Use the provided IDs directly
        await _bulkIntakeOperationsUsecase.updateMultipleIntakes(intakeIds, updatedFields);
        
        _log.info('Successfully updated ${intakeIds.length} entries');
        return FunctionCallResult.success({
          'message': 'Updated ${intakeIds.length} entries',
          'count': intakeIds.length,
          'fields': updatedFields,
        });
      }
    } catch (e) {
      _log.severe('Error updating multiple entries: $e');
      return FunctionCallResult.error('Failed to update entries: $e');
    }
  }

  Future<FunctionCallResult> _executeGetDiaryData(Map<String, dynamic> params) async {
    try {
      _log.info('Starting _executeGetDiaryData with params: $params');
      final dateString = params['date'] as String? ?? 'today';
      final lowerDate = dateString.toLowerCase();
      
      _log.info('Date string: $dateString, lower date: $lowerDate');
      
      // Handle special natural language queries
      if (lowerDate == 'all' || lowerDate == 'everything' || lowerDate == 'all entries') {
        _log.info('Calling _getAllDiaryData()');
        return await _getAllDiaryData();
      } else if (lowerDate == 'earliest' || lowerDate == 'first' || lowerDate == 'oldest') {
        _log.info('Calling _getEarliestEntry()');
        return await _getEarliestEntry();
      } else if (lowerDate == 'latest' || lowerDate == 'last' || lowerDate == 'newest') {
        _log.info('Calling _getLatestEntry()');
        return await _getLatestEntry();
      }
      
      _log.info('No special case matched, handling regular date parsing');
      
      // Handle regular date parsing
      final targetDate = _parseDate(dateString);
      if (targetDate == null) {
        return FunctionCallResult.error('Invalid date: $dateString. Please use "today", "yesterday", "tomorrow", or a specific date like "2024-01-15"');
      }

      final diaryData = await _chatDiaryDataUsecase.getDiaryDataForAI(
        specificDate: targetDate,
        includeFoodEntries: true,
        includeProgress: true,
      );

      return FunctionCallResult.success({
        'message': 'Retrieved diary data for ${targetDate.toString().split(' ')[0]}',
        'data': diaryData,
        'date': targetDate.toString(),
      });
    } catch (e) {
      _log.severe('Error getting diary data: $e');
      return FunctionCallResult.error('Failed to get diary data: $e');
    }
  }

  Future<FunctionCallResult> _getAllDiaryData() async {
    try {
      // Get all food entries from the last 30 days
      final entries = await _chatDiaryDataUsecase.getRecentFoodEntries(days: 30);
      
      _log.info('Retrieved ${entries.length} food entries from the last 30 days');
      
      if (entries.isEmpty) {
        _log.info('No food entries found in diary - user has no entries');
        return FunctionCallResult.success({
          'message': 'No food entries found in your diary. You can add food entries by using the "Add Food" feature or asking me to add food for you.',
          'data': {'foodEntries': [], 'message': 'No entries found'},
          'date': 'all',
        });
      }
      
      // Convert entries to a structured format for the AI
      final foodEntries = entries.map((e) => {
        'name': e.meal.name,
        'date': e.dateTime.toString().split(' ')[0],
        'calories': e.totalKcal,
        'mealType': e.type.toString().split('.').last,
        'amount': e.amount,
        'unit': e.unit,
      }).toList();
      
      _log.info('Successfully converted ${foodEntries.length} entries to structured format');
      
      return FunctionCallResult.success({
        'message': 'Retrieved all your diary entries',
        'data': {
          'foodEntries': foodEntries,
          'totalEntries': foodEntries.length,
          'totalCalories': foodEntries.fold(0.0, (sum, entry) => sum + (entry['calories'] as double)),
        },
        'date': 'all',
      });
    } catch (e) {
      _log.severe('Error getting all diary data: $e');
      return FunctionCallResult.error('Failed to get all diary data: $e');
    }
  }

  Future<FunctionCallResult> _getEarliestEntry() async {
    try {
      // Get all food entries from the last 30 days to find the earliest
      final entries = await _chatDiaryDataUsecase.getRecentFoodEntries(days: 30);
      
      if (entries.isEmpty) {
        return FunctionCallResult.success({
          'message': 'No food entries found in your diary',
          'data': {'foodEntries': [], 'message': 'No entries found'},
          'date': 'earliest',
        });
      }
      
      // Sort by date and get the earliest
      entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final earliestEntry = entries.first;
      
      return FunctionCallResult.success({
        'message': 'Your earliest entry is ${earliestEntry.meal.name} from ${earliestEntry.dateTime.toString().split(' ')[0]}',
        'data': {
          'earliestEntry': {
            'name': earliestEntry.meal.name,
            'date': earliestEntry.dateTime.toString().split(' ')[0],
            'calories': earliestEntry.totalKcal,
            'mealType': earliestEntry.type.toString().split('.').last,
          },
          'allEntries': entries.map((e) => {
            'name': e.meal.name,
            'date': e.dateTime.toString().split(' ')[0],
            'calories': e.totalKcal,
            'mealType': e.type.toString().split('.').last,
          }).toList(),
        },
        'date': 'earliest',
      });
    } catch (e) {
      _log.severe('Error getting earliest entry: $e');
      return FunctionCallResult.error('Failed to get earliest entry: $e');
    }
  }

  Future<FunctionCallResult> _getLatestEntry() async {
    try {
      // Get all food entries from the last 30 days to find the latest
      final entries = await _chatDiaryDataUsecase.getRecentFoodEntries(days: 30);
      
      if (entries.isEmpty) {
        return FunctionCallResult.success({
          'message': 'No food entries found in your diary',
          'data': {'foodEntries': [], 'message': 'No entries found'},
          'date': 'latest',
        });
      }
      
      // Sort by date and get the latest
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final latestEntry = entries.first;
      
      return FunctionCallResult.success({
        'message': 'Your latest entry is ${latestEntry.meal.name} from ${latestEntry.dateTime.toString().split(' ')[0]}',
        'data': {
          'latestEntry': {
            'name': latestEntry.meal.name,
            'date': latestEntry.dateTime.toString().split(' ')[0],
            'calories': latestEntry.totalKcal,
            'mealType': latestEntry.type.toString().split('.').last,
          },
          'allEntries': entries.map((e) => {
            'name': e.meal.name,
            'date': e.dateTime.toString().split(' ')[0],
            'calories': e.totalKcal,
            'mealType': e.type.toString().split('.').last,
          }).toList(),
        },
        'date': 'latest',
      });
    } catch (e) {
      _log.severe('Error getting latest entry: $e');
      return FunctionCallResult.error('Failed to get latest entry: $e');
    }
  }

  Future<FunctionCallResult> _executeGetProgressSummary(Map<String, dynamic> params) async {
    try {
      final daysParam = params['days'];
      int days;
      if (daysParam is int) {
        days = daysParam;
      } else if (daysParam is String) {
        days = int.tryParse(daysParam) ?? 7;
      } else {
        days = 7;
      }
      
      final progressSummary = await _chatDiaryDataUsecase.getRecentProgressSummary(days: days);

      return FunctionCallResult.success({
        'message': 'Retrieved progress summary for last $days days',
        'data': progressSummary,
        'days': days,
      });
    } catch (e) {
      _log.severe('Error getting progress summary: $e');
      return FunctionCallResult.error('Failed to get progress summary: $e');
    }
  }

  // Helper methods
  DateTime? _parseDate(String dateString) {
    try {
      final lowerDate = dateString.toLowerCase();
      
      // Handle common natural language dates
      if (lowerDate == 'today' || lowerDate == 'now') {
        return DateTime.now();
      } else if (lowerDate == 'yesterday') {
        return DateTime.now().subtract(const Duration(days: 1));
      } else if (lowerDate == 'tomorrow') {
        return DateTime.now().add(const Duration(days: 1));
      } else if (lowerDate == 'day before yesterday') {
        return DateTime.now().subtract(const Duration(days: 2));
      } else if (lowerDate == 'day after tomorrow') {
        return DateTime.now().add(const Duration(days: 2));
      }
      
      // Handle day names like "monday", "tuesday", etc.
      final dayNames = {
        'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
        'friday': 5, 'saturday': 6, 'sunday': 0
      };
      
      if (dayNames.containsKey(lowerDate)) {
        final today = DateTime.now();
        final targetDay = dayNames[lowerDate]!;
        final currentDay = today.weekday;
        final daysToAdd = ((targetDay - currentDay) % 7 + 7) % 7;
        return today.add(Duration(days: daysToAdd));
      }
      
      // Try to parse as ISO date string (YYYY-MM-DD)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        return DateTime.parse(dateString);
      }
      
      // Try to parse as MM/DD/YYYY
      final slashPattern = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final slashMatch = slashPattern.firstMatch(dateString);
      if (slashMatch != null) {
        final firstStr = slashMatch.group(1);
        final secondStr = slashMatch.group(2);
        final yearStr = slashMatch.group(3);
        
        if (firstStr != null && secondStr != null && yearStr != null) {
          final first = int.tryParse(firstStr);
          final second = int.tryParse(secondStr);
          final year = int.tryParse(yearStr);
          
          if (first != null && second != null && year != null) {
            // Assume MM/DD/YYYY format (US format)
            return DateTime(year, first, second);
          }
        }
      }
      
      _log.warning('Could not parse date: $dateString');
      return null;
    } catch (e) {
      _log.warning('Error parsing date: $dateString - $e');
      return null;
    }
  }

  double _parseNumericParam(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

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
        return IntakeTypeEntity.snack;
    }
  }

  IntakeTypeEntity? _getCurrentMealTypeFromFields(Map<String, dynamic> fields) {
    if (fields.containsKey('mealType')) {
      final mealType = fields['mealType'] as String;
      return _getIntakeTypeFromString(mealType);
    }
    return null;
  }
} 