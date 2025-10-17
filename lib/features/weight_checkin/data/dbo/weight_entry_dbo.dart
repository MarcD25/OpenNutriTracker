import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

part 'weight_entry_dbo.g.dart';

@HiveType(typeId: 21)
@JsonSerializable()
class WeightEntryDBO extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  double weightKG;
  
  @HiveField(2)
  DateTime timestamp;
  
  @HiveField(3)
  String? notes;
  
  @HiveField(4)
  double? bodyFatPercentage;
  
  @HiveField(5)
  double? muscleMass;

  WeightEntryDBO({
    required this.id,
    required this.weightKG,
    required this.timestamp,
    this.notes,
    this.bodyFatPercentage,
    this.muscleMass,
  });

  factory WeightEntryDBO.fromWeightEntryEntity(WeightEntryEntity entity) {
    return WeightEntryDBO(
      id: entity.id,
      weightKG: entity.weightKG,
      timestamp: entity.timestamp,
      notes: entity.notes,
      bodyFatPercentage: entity.bodyFatPercentage,
      muscleMass: entity.muscleMass,
    );
  }

  factory WeightEntryDBO.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryDBOFromJson(json);

  Map<String, dynamic> toJson() => _$WeightEntryDBOToJson(this);
}