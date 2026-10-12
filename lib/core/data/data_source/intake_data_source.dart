import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/intake_dbo.dart';
import 'package:opennutritracker/core/data/dbo/intake_type_dbo.dart';

class IntakeDataSource {
  final log = Logger('IntakeDataSource');
  final Box<IntakeDBO> _intakeBox;

  IntakeDataSource(this._intakeBox);

  Future<void> addIntake(IntakeDBO intakeDBO) async {
    log.fine('Adding new intake item to db');
    _intakeBox.add(intakeDBO);
  }

  Future<void> addAllIntakes(List<IntakeDBO> intakeDBOList) async {
    log.fine('Adding new intake items to db');
    _intakeBox.addAll(intakeDBOList);
  }

  Future<void> deleteIntakeFromId(String intakeId) async {
    log.fine('Deleting intake item from db');
    _intakeBox.values
        .where((dbo) => dbo.id == intakeId)
        .toList()
        .forEach((element) {
      element.delete();
    });
  }

  Future<IntakeDBO?> updateIntake(String intakeId, Map<String, dynamic> fields) async {
    log.fine('Updating intake $intakeId with fields ${fields.toString()} in db');
    var intakeObject = _intakeBox.values.indexed
      .where((indexedDbo) => indexedDbo.$2.id == intakeId).firstOrNull;
    if(intakeObject == null) {
      log.fine('Cannot update intake $intakeId as it is non existent');
      return null;
    }
    intakeObject.$2.amount = fields['amount'] ?? intakeObject.$2.amount;
    _intakeBox.putAt(intakeObject.$1, intakeObject.$2);
    return _intakeBox.getAt(intakeObject.$1);
  }

  Future<IntakeDBO?> getIntakeById(String intakeId) async {
    return _intakeBox.values.firstWhereOrNull(
            (intake) => intake.id == intakeId
    );
  }

  Future<List<IntakeDBO>> getAllIntakes() async {
    return _intakeBox.values.toList();
  }

  Future<List<IntakeDBO>> getAllIntakesByDate(
      IntakeTypeDBO intakeType, DateTime dateTime) async {
    return _intakeBox.values
        .where((intake) =>
            DateUtils.isSameDay(dateTime, intake.dateTime) &&
            intake.type == intakeType)
        .toList();
  }

  Future<List<IntakeDBO>> getRecentlyAddedIntake({int number = 100}) async {
    final intakeList = _intakeBox.values.toList();

    //  sort list by date (newest first) and filter unique intake
    intakeList
        .sort((a, b) =>  (-1) * a.dateTime.compareTo(b.dateTime));

    final filterCodes = <String>{};
    final uniqueIntake = intakeList
        .where((intake) =>
            filterCodes.add(intake.meal.code ?? intake.meal.name ?? ""))
        .toList();

    return uniqueIntake.take(number).toList();
  }

  /// Deletes multiple intake entries by their IDs
  Future<void> deleteMultipleIntakesById(List<String> intakeIds) async {
    log.fine('Deleting multiple intake items from db');
    for (final id in intakeIds) {
      final intakes = _intakeBox.values
          .where((dbo) => dbo.id == id)
          .toList();
      for (final intake in intakes) {
        intake.delete();
      }
    }
  }

  /// Deletes all intake entries for a specific date
  Future<void> deleteAllIntakesForDate(DateTime date) async {
    log.fine('Deleting all intake items for date: $date');
    final intakesToDelete = _intakeBox.values
        .where((intake) => DateUtils.isSameDay(date, intake.dateTime))
        .toList();
    for (final intake in intakesToDelete) {
      intake.delete();
    }
  }

  /// Deletes all intake entries for a specific meal type on a specific date
  Future<void> deleteIntakesForDateAndType(DateTime date, IntakeTypeDBO mealType) async {
    log.fine('Deleting intake items for date: $date and type: $mealType');
    final intakesToDelete = _intakeBox.values
        .where((intake) => 
            DateUtils.isSameDay(date, intake.dateTime) && 
            intake.type == mealType)
        .toList();
    for (final intake in intakesToDelete) {
      intake.delete();
    }
  }

  /// Deletes all intake entries for a date range
  Future<void> deleteAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    log.fine('Deleting all intake items for date range: $startDate to $endDate');
    final intakesToDelete = _intakeBox.values
        .where((intake) => 
            intake.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            intake.dateTime.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
    for (final intake in intakesToDelete) {
      intake.delete();
    }
  }

  /// Updates multiple intake entries with the same fields
  Future<void> updateMultipleIntakes(List<String> intakeIds, Map<String, dynamic> fields) async {
    log.fine('Updating multiple intake items with fields: $fields');
    for (final id in intakeIds) {
      await updateIntake(id, fields);
    }
  }

  /// Gets all intake entries for a date range
  Future<List<IntakeDBO>> getAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    return _intakeBox.values
        .where((intake) => 
            intake.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            intake.dateTime.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Gets all intake entries for a specific meal type
  Future<List<IntakeDBO>> getAllIntakesByType(IntakeTypeDBO mealType) async {
    return _intakeBox.values
        .where((intake) => intake.type == mealType)
        .toList();
  }

  /// Gets all intake entries for a specific meal type in a date range
  Future<List<IntakeDBO>> getAllIntakesByTypeAndDateRange(
      IntakeTypeDBO mealType, DateTime startDate, DateTime endDate) async {
    return _intakeBox.values
        .where((intake) => 
            intake.type == mealType &&
            intake.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            intake.dateTime.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
}
