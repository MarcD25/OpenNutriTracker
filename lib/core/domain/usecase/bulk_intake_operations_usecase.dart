import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/repository/intake_repository.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';

class BulkIntakeOperationsUsecase {
  final IntakeRepository _intakeRepository;
  final Logger _log = Logger('BulkIntakeOperationsUsecase');

  BulkIntakeOperationsUsecase(this._intakeRepository);

  /// Deletes multiple intake entries by their IDs
  Future<void> deleteMultipleIntakes(List<String> intakeIds) async {
    try {
      await _intakeRepository.deleteMultipleIntakes(intakeIds);
      _log.info('Successfully deleted ${intakeIds.length} intake entries');
    } catch (e) {
      _log.severe('Error deleting multiple intakes: $e');
      rethrow;
    }
  }

  /// Deletes all intake entries for a specific date
  Future<void> deleteAllIntakesForDate(DateTime date) async {
    try {
      await _intakeRepository.deleteAllIntakesForDate(date);
      _log.info('Successfully deleted all intake entries for date: ${date.toString().split(' ')[0]}');
    } catch (e) {
      _log.severe('Error deleting all intakes for date: $e');
      rethrow;
    }
  }

  /// Deletes all intake entries for a specific meal type on a specific date
  Future<void> deleteIntakesForDateAndType(IntakeTypeEntity mealType, DateTime date) async {
    try {
      await _intakeRepository.deleteIntakesForDateAndType(mealType, date);
      _log.info('Successfully deleted ${mealType.toString().split('.').last} intakes for date: ${date.toString().split(' ')[0]}');
    } catch (e) {
      _log.severe('Error deleting intakes for date and type: $e');
      rethrow;
    }
  }

  /// Deletes all intake entries for a date range
  Future<void> deleteAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      await _intakeRepository.deleteAllIntakesForDateRange(startDate, endDate);
      _log.info('Successfully deleted all intake entries for date range: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}');
    } catch (e) {
      _log.severe('Error deleting intakes for date range: $e');
      rethrow;
    }
  }

  /// Updates multiple intake entries with the same fields
  Future<void> updateMultipleIntakes(List<String> intakeIds, Map<String, dynamic> fields) async {
    try {
      await _intakeRepository.updateMultipleIntakes(intakeIds, fields);
      _log.info('Successfully updated ${intakeIds.length} intake entries with fields: $fields');
    } catch (e) {
      _log.severe('Error updating multiple intakes: $e');
      rethrow;
    }
  }

  /// Gets all intake entries for a date range
  Future<List<IntakeEntity>> getAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final intakes = await _intakeRepository.getAllIntakesForDateRange(startDate, endDate);
      _log.info('Retrieved ${intakes.length} intake entries for date range: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}');
      return intakes;
    } catch (e) {
      _log.severe('Error getting intakes for date range: $e');
      return [];
    }
  }

  /// Gets all intake entries for a specific meal type
  Future<List<IntakeEntity>> getAllIntakesByType(IntakeTypeEntity mealType) async {
    try {
      final intakes = await _intakeRepository.getAllIntakesByType(mealType);
      _log.info('Retrieved ${intakes.length} intake entries for meal type: ${mealType.toString().split('.').last}');
      return intakes;
    } catch (e) {
      _log.severe('Error getting intakes by type: $e');
      return [];
    }
  }

  /// Gets all intake entries for a specific meal type in a date range
  Future<List<IntakeEntity>> getAllIntakesByTypeAndDateRange(
      IntakeTypeEntity mealType, DateTime startDate, DateTime endDate) async {
    try {
      final intakes = await _intakeRepository.getAllIntakesByTypeAndDateRange(mealType, startDate, endDate);
      _log.info('Retrieved ${intakes.length} intake entries for meal type ${mealType.toString().split('.').last} in date range: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}');
      return intakes;
    } catch (e) {
      _log.severe('Error getting intakes by type and date range: $e');
      return [];
    }
  }

  /// Deletes all intake entries for a specific meal type across all dates
  Future<void> deleteAllIntakesByType(IntakeTypeEntity mealType) async {
    try {
      final intakes = await getAllIntakesByType(mealType);
      final intakeIds = intakes.map((intake) => intake.id).toList();
      await deleteMultipleIntakes(intakeIds);
      _log.info('Successfully deleted all intake entries for meal type: ${mealType.toString().split('.').last}');
    } catch (e) {
      _log.severe('Error deleting all intakes by type: $e');
      rethrow;
    }
  }

  /// Deletes all intake entries for a specific meal type in a date range
  Future<void> deleteIntakesByTypeAndDateRange(IntakeTypeEntity mealType, DateTime startDate, DateTime endDate) async {
    try {
      final intakes = await getAllIntakesByTypeAndDateRange(mealType, startDate, endDate);
      final intakeIds = intakes.map((intake) => intake.id).toList();
      await deleteMultipleIntakes(intakeIds);
      _log.info('Successfully deleted intake entries for meal type ${mealType.toString().split('.').last} in date range: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}');
    } catch (e) {
      _log.severe('Error deleting intakes by type and date range: $e');
      rethrow;
    }
  }

  /// Gets a summary of bulk operations that can be performed
  String getBulkOperationsSummary() {
    return '''
**Available Bulk Operations:**

**Mass Delete Operations:**
- Delete all entries for a specific date
- Delete all entries for a specific meal type (breakfast/lunch/dinner/snack)
- Delete all entries for a date range
- Delete all entries for a specific meal type in a date range
- Delete multiple specific entries by ID

**Mass Edit Operations:**
- Update amount for multiple entries
- Update meal type for multiple entries
- Update unit for multiple entries

**Mass Add Operations:**
- Add multiple food entries for a specific date
- Add multiple food entries for a date range
- Add multiple food entries for different meal types

**Examples:**
- "Delete all breakfast entries for yesterday"
- "Delete all entries for last week"
- "Update all snack entries to have 50g amount"
- "Add 5 food entries for today"
- "Delete all entries for January 2024"
''';
  }
} 