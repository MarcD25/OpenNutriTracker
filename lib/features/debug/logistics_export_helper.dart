import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/data/dbo/logistics_event_dbo.dart';
import 'package:path_provider/path_provider.dart';

class LogisticsExportHelper {
  static Future<String> exportLogsToJson() async {
    try {
      // Open the logistics box
      final box = await Hive.openBox<LogisticsEventDBO>('LogisticsBox');
      
      // Convert all events to JSON
      final events = box.values.map((event) => {
        'id': event.id,
        'eventType': event.eventType,
        'timestamp': event.timestamp.millisecondsSinceEpoch,
        'eventData': event.eventData,
        'userId': event.userId,
        'metadata': event.metadata,
      }).toList();
      
      // Create JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'exportDate': DateTime.now().toIso8601String(),
        'totalEvents': events.length,
        'events': events,
      });
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/logistics_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export logs: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getLogisticsStats() async {
    try {
      final box = await Hive.openBox<LogisticsEventDBO>('LogisticsBox');
      final events = box.values.toList();
      
      // Calculate statistics
      final eventTypeCounts = <String, int>{};
      final last24Hours = DateTime.now().subtract(const Duration(hours: 24));
      int recentEvents = 0;
      
      for (final event in events) {
        // Count by type
        final typeName = event.eventType;
        eventTypeCounts[typeName] = (eventTypeCounts[typeName] ?? 0) + 1;
        
        // Count recent events
        if (event.timestamp.isAfter(last24Hours)) {
          recentEvents++;
        }
      }
      
      return {
        'totalEvents': events.length,
        'recentEvents24h': recentEvents,
        'eventTypeCounts': eventTypeCounts,
        'oldestEvent': events.isNotEmpty 
            ? events.first.timestamp.toIso8601String()
            : null,
        'newestEvent': events.isNotEmpty 
            ? events.last.timestamp.toIso8601String()
            : null,
      };
    } catch (e) {
      throw Exception('Failed to get logistics stats: $e');
    }
  }
}