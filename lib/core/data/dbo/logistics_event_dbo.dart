import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';

part 'logistics_event_dbo.g.dart';

@HiveType(typeId: 20)
@JsonSerializable()
class LogisticsEventDBO extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String eventType;
  
  @HiveField(2)
  String eventData;
  
  @HiveField(3)
  DateTime timestamp;
  
  @HiveField(4)
  String? userId;
  
  @HiveField(5)
  Map<String, dynamic>? metadata;

  LogisticsEventDBO({
    required this.id,
    required this.eventType,
    required this.eventData,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  factory LogisticsEventDBO.fromLogisticsEventEntity(LogisticsEventEntity entity) {
    return LogisticsEventDBO(
      id: entity.id,
      eventType: entity.eventType.name,
      eventData: entity.eventDataJson,
      timestamp: entity.timestamp,
      userId: entity.userId,
      metadata: entity.metadata,
    );
  }

  factory LogisticsEventDBO.fromJson(Map<String, dynamic> json) =>
      _$LogisticsEventDBOFromJson(json);

  Map<String, dynamic> toJson() => _$LogisticsEventDBOToJson(this);
}