import 'package:opennutritracker/core/data/data_source/intake_data_source.dart';
import 'package:opennutritracker/core/data/dbo/intake_dbo.dart';
import 'package:opennutritracker/core/data/dbo/intake_type_dbo.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';

class IntakeRepository {
  final IntakeDataSource _intakeDataSource;

  IntakeRepository(this._intakeDataSource);

  Future<void> addIntake(IntakeEntity intakeEntity) async {
    final intakeDBO = IntakeDBO.fromIntakeEntity(intakeEntity);

    await _intakeDataSource.addIntake(intakeDBO);
  }

  Future<void> addAllIntakeDBOs(List<IntakeDBO> intakeDBOs) async {
    await _intakeDataSource.addAllIntakes(intakeDBOs);
  }

  Future<void> deleteIntake(IntakeEntity intakeEntity) async {
    await _intakeDataSource.deleteIntakeFromId(intakeEntity.id);
  }

  Future<IntakeEntity?> updateIntake(
      String intakeId, Map<String, dynamic> fields) async {
    var result = await _intakeDataSource.updateIntake(intakeId, fields);
    return result == null ? null : IntakeEntity.fromIntakeDBO(result);
  }

  Future<List<IntakeDBO>> getAllIntakesDBO() async {
    return await _intakeDataSource.getAllIntakes();
  }

  Future<List<IntakeEntity>> getIntakeByDateAndType(
      IntakeTypeEntity intakeType, DateTime date) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesByDate(
        IntakeTypeDBO.fromIntakeTypeEntity(intakeType), date);

    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<List<IntakeEntity>> getRecentIntake() async {
    final intakeList = await _intakeDataSource.getRecentlyAddedIntake();

    return intakeList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  Future<IntakeEntity?> getIntakeById(String intakeId) async {
    final result = await _intakeDataSource.getIntakeById(intakeId);
    return result == null ? null : IntakeEntity.fromIntakeDBO(result);
  }

  /// Deletes multiple intake entries by their IDs
  Future<void> deleteMultipleIntakes(List<String> intakeIds) async {
    await _intakeDataSource.deleteMultipleIntakesById(intakeIds);
  }

  /// Deletes all intake entries for a specific date
  Future<void> deleteAllIntakesForDate(DateTime date) async {
    await _intakeDataSource.deleteAllIntakesForDate(date);
  }

  /// Deletes all intake entries for a specific meal type on a specific date
  Future<void> deleteIntakesForDateAndType(IntakeTypeEntity mealType, DateTime date) async {
    await _intakeDataSource.deleteIntakesForDateAndType(
      date, 
      IntakeTypeDBO.fromIntakeTypeEntity(mealType)
    );
  }

  /// Deletes all intake entries for a date range
  Future<void> deleteAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    await _intakeDataSource.deleteAllIntakesForDateRange(startDate, endDate);
  }

  /// Updates multiple intake entries with the same fields
  Future<void> updateMultipleIntakes(List<String> intakeIds, Map<String, dynamic> fields) async {
    await _intakeDataSource.updateMultipleIntakes(intakeIds, fields);
  }

  /// Gets all intake entries for a date range
  Future<List<IntakeEntity>> getAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesForDateRange(startDate, endDate);
    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  /// Gets all intake entries for a specific meal type
  Future<List<IntakeEntity>> getAllIntakesByType(IntakeTypeEntity mealType) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesByType(
      IntakeTypeDBO.fromIntakeTypeEntity(mealType)
    );
    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }

  /// Gets all intake entries for a specific meal type in a date range
  Future<List<IntakeEntity>> getAllIntakesByTypeAndDateRange(
      IntakeTypeEntity mealType, DateTime startDate, DateTime endDate) async {
    final intakeDBOList = await _intakeDataSource.getAllIntakesByTypeAndDateRange(
      IntakeTypeDBO.fromIntakeTypeEntity(mealType),
      startDate,
      endDate
    );
    return intakeDBOList
        .map((intakeDBO) => IntakeEntity.fromIntakeDBO(intakeDBO))
        .toList();
  }
}
