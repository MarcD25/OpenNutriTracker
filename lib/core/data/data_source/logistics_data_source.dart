import 'dart:async';
import 'dart:isolate';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/logistics_event_dbo.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/core/domain/service/memory_management_service.dart';

class LogisticsDataSource with MemoryManagementMixin {
  static const int maxLogEntries = 10000; // Maximum entries before rotation
  static const int _batchSize = 50; // Batch size for efficient writes
  static const Duration _batchTimeout = Duration(seconds: 30); // Max time to wait for batch
  
  final log = Logger('LogisticsDataSource');
  final Box<LogisticsEventDBO> _logisticsBox;
  
  // Batching variables
  final List<LogisticsEventEntity> _pendingEvents = [];
  Timer? _batchTimer;
  bool _isProcessingBatch = false;
  final Completer<void> _initCompleter = Completer<void>();

  LogisticsDataSource(this._logisticsBox) {
    _startBatchTimer();
    _initCompleter.complete();
  }

  Future<void> logUserAction(LogisticsEventEntity event) async {
    try {
      await _initCompleter.future;
      log.fine('Queuing user action for batch: ${event.eventType.name}');
      
      _pendingEvents.add(event);
      
      // Process batch if it reaches the batch size
      if (_pendingEvents.length >= _batchSize) {
        await _processBatch();
      }
    } catch (e) {
      log.warning('Failed to queue user action: $e');
      // Fail silently to not disrupt user experience
    }
  }

  Future<void> logChatInteraction(String message, String response, Duration responseTime) async {
    try {
      final event = LogisticsEventEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventType: LogisticsEventType.chatInteraction,
        eventData: {
          'message_length': message.length,
          'response_length': response.length,
          'response_time_ms': responseTime.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
        timestamp: DateTime.now(),
        metadata: {
          'interaction_type': 'chat',
          'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      
      await logUserAction(event);
    } catch (e) {
      log.warning('Failed to log chat interaction: $e');
    }
  }

  Future<void> logNavigation(String fromScreen, String toScreen) async {
    try {
      final event = LogisticsEventEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventType: LogisticsEventType.screenNavigation,
        eventData: {
          'from_screen': fromScreen,
          'to_screen': toScreen,
          'timestamp': DateTime.now().toIso8601String(),
        },
        timestamp: DateTime.now(),
        metadata: {
          'navigation_type': 'screen_change',
        },
      );
      
      await logUserAction(event);
    } catch (e) {
      log.warning('Failed to log navigation: $e');
    }
  }

  Future<void> rotateLogsIfNeeded() async {
    await _rotateLogsIfNeeded();
  }

  Future<void> _rotateLogsIfNeeded() async {
    try {
      if (_logisticsBox.length > maxLogEntries) {
        log.info('Rotating logistics logs - current count: ${_logisticsBox.length}');
        
        // Keep only the most recent 70% of entries
        final keepCount = (maxLogEntries * 0.7).round();
        final allEntries = _logisticsBox.values.toList();
        
        // Sort by timestamp (newest first)
        allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Clear the box and add back the most recent entries
        await _logisticsBox.clear();
        final entriesToKeep = allEntries.take(keepCount).toList();
        
        for (final entry in entriesToKeep.reversed) {
          await _logisticsBox.add(entry);
        }
        
        log.info('Log rotation completed - kept $keepCount entries');
      }
    } catch (e) {
      log.warning('Failed to rotate logs: $e');
    }
  }

  Future<List<LogisticsEventDBO>> getLogsByDateRange(DateTime start, DateTime end) async {
    try {
      return _logisticsBox.values
          .where((event) => 
              event.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
              event.timestamp.isBefore(end.add(const Duration(days: 1))))
          .toList();
    } catch (e) {
      log.warning('Failed to get logs by date range: $e');
      return [];
    }
  }

  Future<List<LogisticsEventDBO>> getAllLogs() async {
    try {
      return _logisticsBox.values.toList();
    } catch (e) {
      log.warning('Failed to get all logs: $e');
      return [];
    }
  }

  Future<List<LogisticsEventDBO>> getLogsByEventType(LogisticsEventType eventType) async {
    try {
      return _logisticsBox.values
          .where((event) => event.eventType == eventType.name)
          .toList();
    } catch (e) {
      log.warning('Failed to get logs by event type: $e');
      return [];
    }
  }

  Future<int> getLogCount() async {
    try {
      return _logisticsBox.length;
    } catch (e) {
      log.warning('Failed to get log count: $e');
      return 0;
    }
  }

  Future<void> clearAllLogs() async {
    try {
      log.info('Clearing all logistics logs');
      await _logisticsBox.clear();
    } catch (e) {
      log.warning('Failed to clear logs: $e');
    }
  }

  Future<List<LogisticsEventDBO>> getRecentLogs({int limit = 100}) async {
    try {
      final allLogs = _logisticsBox.values.toList();
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allLogs.take(limit).toList();
    } catch (e) {
      log.warning('Failed to get recent logs: $e');
      return [];
    }
  }

  // Batching methods for performance optimization
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = MemoryManagementService().createManagedPeriodicTimer(
      _batchTimeout,
      (_) async {
        if (_pendingEvents.isNotEmpty && !_isProcessingBatch) {
          await _processBatch();
        }
      },
      name: 'LogisticsBatchTimer',
    );
  }

  Future<void> _processBatch() async {
    if (_isProcessingBatch || _pendingEvents.isEmpty) return;
    
    _isProcessingBatch = true;
    try {
      final eventsToProcess = List<LogisticsEventEntity>.from(_pendingEvents);
      _pendingEvents.clear();
      
      log.fine('Processing batch of ${eventsToProcess.length} events');
      
      // Use isolate for heavy processing if batch is large
      if (eventsToProcess.length > 20) {
        await _processBatchInIsolate(eventsToProcess);
      } else {
        await _processBatchDirectly(eventsToProcess);
      }
      
      // Check if rotation is needed after batch processing
      await _rotateLogsIfNeeded();
    } catch (e) {
      log.warning('Failed to process batch: $e');
    } finally {
      _isProcessingBatch = false;
    }
  }

  Future<void> _processBatchDirectly(List<LogisticsEventEntity> events) async {
    final dbos = events.map((event) => LogisticsEventDBO.fromLogisticsEventEntity(event)).toList();
    await _logisticsBox.addAll(dbos);
  }

  Future<void> _processBatchInIsolate(List<LogisticsEventEntity> events) async {
    try {
      // For now, process directly as Hive boxes can't be passed to isolates easily
      // In a production app, you might serialize the data and process in isolate
      await _processBatchDirectly(events);
    } catch (e) {
      log.warning('Failed to process batch in isolate, falling back to direct processing: $e');
      await _processBatchDirectly(events);
    }
  }

  Future<void> flushPendingEvents() async {
    if (_pendingEvents.isNotEmpty) {
      await _processBatch();
    }
  }

  void dispose() {
    // Flush any remaining events before disposing
    if (_pendingEvents.isNotEmpty) {
      _processBatch();
    }
    
    // Clean up memory resources
    cleanupMemory();
    _pendingEvents.clear();
    
    log.info('LogisticsDataSource disposed');
  }
}