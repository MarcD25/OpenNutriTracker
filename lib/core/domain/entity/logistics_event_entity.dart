import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/data/dbo/logistics_event_dbo.dart';

enum LogisticsEventType {
  mealLogged,
  exerciseLogged,
  weightCheckin,
  chatInteraction,
  screenNavigation,
  settingsChanged,
  goalUpdated,
  appLaunched,
  appClosed,
  userAction,
}

class LogisticsEventEntity extends Equatable {
  final String id;
  final LogisticsEventType eventType;
  final Map<String, dynamic> eventData;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  const LogisticsEventEntity({
    required this.id,
    required this.eventType,
    required this.eventData,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  factory LogisticsEventEntity.fromLogisticsEventDBO(LogisticsEventDBO dbo) {
    return LogisticsEventEntity(
      id: dbo.id,
      eventType: LogisticsEventType.values.firstWhere(
        (type) => type.name == dbo.eventType,
        orElse: () => LogisticsEventType.userAction,
      ),
      eventData: _parseEventData(dbo.eventData),
      timestamp: dbo.timestamp,
      userId: dbo.userId,
      metadata: dbo.metadata,
    );
  }

  static Map<String, dynamic> _parseEventData(String eventDataJson) {
    try {
      return json.decode(eventDataJson) as Map<String, dynamic>;
    } catch (e) {
      return {'raw_data': eventDataJson};
    }
  }

  String get eventDataJson => json.encode(eventData);

  @override
  List<Object?> get props => [id, eventType, eventData, timestamp, userId, metadata];
}