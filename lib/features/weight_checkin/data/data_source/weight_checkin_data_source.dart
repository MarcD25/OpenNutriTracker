import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:opennutritracker/features/weight_checkin/data/dbo/weight_entry_dbo.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

class WeightCheckinDataSource {
  static const _configKey = "ConfigKey";
  final HiveDBProvider _hiveDBProvider;

  WeightCheckinDataSource(this._hiveDBProvider);

  Future<void> saveWeightEntry(WeightEntryDBO weightEntry) async {
    await _hiveDBProvider.weightCheckinBox.put(weightEntry.id, weightEntry);
  }

  Future<List<WeightEntryDBO>> getWeightHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allEntries = _hiveDBProvider.weightCheckinBox.values.toList();
    
    if (startDate == null && endDate == null) {
      return allEntries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return allEntries.where((entry) {
      if (startDate != null && entry.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && entry.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<WeightEntryDBO?> getLatestWeightEntry() async {
    final entries = await getWeightHistory();
    return entries.isNotEmpty ? entries.first : null;
  }

  Future<void> setCheckinFrequency(CheckinFrequency frequency) async {
    final config = _hiveDBProvider.configBox.get(_configKey);
    if (config != null) {
      config.checkinFrequency = frequency.name;
      await config.save();
    }
  }

  Future<CheckinFrequency> getCheckinFrequency() async {
    final config = _hiveDBProvider.configBox.get(_configKey);
    final frequencyName = config?.checkinFrequency ?? 'weekly';
    return CheckinFrequency.values.firstWhere(
      (freq) => freq.name == frequencyName,
      orElse: () => CheckinFrequency.weekly,
    );
  }

  Future<DateTime?> getNextCheckinDate() async {
    final config = _hiveDBProvider.configBox.get(_configKey);
    final lastCheckinDateString = config?.lastCheckinDate;
    if (lastCheckinDateString == null) return null;
    
    final lastCheckinDate = DateTime.parse(lastCheckinDateString);
    final frequency = await getCheckinFrequency();
    
    switch (frequency) {
      case CheckinFrequency.daily:
        return lastCheckinDate.add(const Duration(days: 1));
      case CheckinFrequency.weekly:
        return lastCheckinDate.add(const Duration(days: 7));
      case CheckinFrequency.biweekly:
        return lastCheckinDate.add(const Duration(days: 14));
      case CheckinFrequency.monthly:
        return DateTime(lastCheckinDate.year, lastCheckinDate.month + 1, lastCheckinDate.day);
    }
  }

  Future<void> updateLastCheckinDate(DateTime date) async {
    final config = _hiveDBProvider.configBox.get(_configKey);
    if (config != null) {
      config.lastCheckinDate = date.toIso8601String();
      await config.save();
    }
  }

  Future<void> deleteWeightEntry(String id) async {
    await _hiveDBProvider.weightCheckinBox.delete(id);
  }
}