import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/weight_checkin/data/dbo/weight_entry_dbo.dart';

enum CheckinFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
}

class WeightEntryEntity extends Equatable {
  final String id;
  final double weightKG;
  final DateTime timestamp;
  final String? notes;
  final double? bodyFatPercentage;
  final double? muscleMass;

  const WeightEntryEntity({
    required this.id,
    required this.weightKG,
    required this.timestamp,
    this.notes,
    this.bodyFatPercentage,
    this.muscleMass,
  });

  factory WeightEntryEntity.fromWeightEntryDBO(WeightEntryDBO dbo) {
    return WeightEntryEntity(
      id: dbo.id,
      weightKG: dbo.weightKG,
      timestamp: dbo.timestamp,
      notes: dbo.notes,
      bodyFatPercentage: dbo.bodyFatPercentage,
      muscleMass: dbo.muscleMass,
    );
  }

  // Calculated properties
  double get weightLbs => weightKG * 2.20462;

  @override
  List<Object?> get props => [
        id,
        weightKG,
        timestamp,
        notes,
        bodyFatPercentage,
        muscleMass,
      ];
}