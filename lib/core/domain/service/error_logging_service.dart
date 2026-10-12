import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../exception/app_exception.dart';

/// Service for logging errors for debugging and analytics
class ErrorLoggingService {
  static final ErrorLoggingService _instance = ErrorLoggingService._internal();
  factory ErrorLoggingService() => _instance;
  ErrorLoggingService._internal();

  static const String _errorLogFileName = 'error_logs.json';
  static const int _maxLogEntries = 1000;
  static const int _maxLogFileSizeBytes = 5 * 1024 * 1024; // 5MB

  /// Log an error with context information
  Future<void> logError(
    AppException error, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    try {
      final logEntry = ErrorLogEntry(
        timestamp: DateTime.now(),
        errorType: error.runtimeType.toString(),
        message: error.message,
        code: error.code,
        severity: _getSeverity(error),
        stackTrace: error.stackTrace?.toString(),
        context: context,
        userId: userId,
        platform: Platform.operatingSystem,
        appVersion: await _getAppVersion(),
      );

      await _writeLogEntry(logEntry);
      
      // Also log to console in debug mode
      if (kDebugMode) {
        debugPrint('ERROR: ${logEntry.toJson()}');
      }
    } catch (e) {
      // Fail silently to avoid recursive error logging
      if (kDebugMode) {
        debugPrint('Failed to log error: $e');
      }
    }
  }

  /// Log a custom error message
  Future<void> logCustomError(
    String message, {
    String? errorType,
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    String? userId,
    StackTrace? stackTrace,
  }) async {
    final error = AppException(
      message,
      code: code,
      stackTrace: stackTrace,
    );

    await logError(
      error,
      context: {
        ...?context,
        'customErrorType': errorType,
        'customSeverity': severity.toString(),
      },
      userId: userId,
    );
  }

  /// Get error logs for debugging
  Future<List<ErrorLogEntry>> getErrorLogs({
    DateTime? since,
    ErrorSeverity? minSeverity,
    int? limit,
  }) async {
    try {
      final file = await _getLogFile();
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty);
      
      List<ErrorLogEntry> logs = [];
      for (final line in lines) {
        try {
          final json = jsonDecode(line);
          final entry = ErrorLogEntry.fromJson(json);
          
          // Apply filters
          if (since != null && entry.timestamp.isBefore(since)) continue;
          if (minSeverity != null && _compareSeverity(entry.severity, minSeverity) < 0) continue;
          
          logs.add(entry);
        } catch (e) {
          // Skip malformed log entries
          continue;
        }
      }

      // Sort by timestamp (newest first) and apply limit
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && logs.length > limit) {
        logs = logs.take(limit).toList();
      }

      return logs;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read error logs: $e');
      }
      return [];
    }
  }

  /// Clear old error logs
  Future<void> clearOldLogs({Duration? olderThan}) async {
    try {
      final cutoffDate = DateTime.now().subtract(olderThan ?? const Duration(days: 30));
      final logs = await getErrorLogs(since: cutoffDate);
      
      final file = await _getLogFile();
      final buffer = StringBuffer();
      
      for (final log in logs) {
        buffer.writeln(jsonEncode(log.toJson()));
      }
      
      await file.writeAsString(buffer.toString());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear old logs: $e');
      }
    }
  }

  /// Get error statistics
  Future<ErrorStatistics> getErrorStatistics({Duration? period}) async {
    final since = period != null ? DateTime.now().subtract(period) : null;
    final logs = await getErrorLogs(since: since);
    
    final stats = ErrorStatistics();
    
    for (final log in logs) {
      stats.totalErrors++;
      
      switch (log.severity) {
        case ErrorSeverity.critical:
          stats.criticalErrors++;
          break;
        case ErrorSeverity.error:
          stats.errors++;
          break;
        case ErrorSeverity.warning:
          stats.warnings++;
          break;
        case ErrorSeverity.info:
          stats.infoMessages++;
          break;
      }
      
      // Count by error type
      stats.errorsByType[log.errorType] = (stats.errorsByType[log.errorType] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Write log entry to file
  Future<void> _writeLogEntry(ErrorLogEntry entry) async {
    final file = await _getLogFile();
    
    // Check file size and rotate if needed
    if (await file.exists()) {
      final fileSize = await file.length();
      if (fileSize > _maxLogFileSizeBytes) {
        await _rotateLogFile(file);
      }
    }
    
    // Append new log entry
    final logLine = jsonEncode(entry.toJson());
    await file.writeAsString('$logLine\n', mode: FileMode.append);
  }

  /// Rotate log file when it gets too large
  Future<void> _rotateLogFile(File file) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      // Keep only the most recent entries
      final keepLines = lines.length > _maxLogEntries 
          ? lines.skip(lines.length - _maxLogEntries).toList()
          : lines;
      
      await file.writeAsString(keepLines.join('\n') + '\n');
    } catch (e) {
      // If rotation fails, just clear the file
      await file.writeAsString('');
    }
  }

  /// Get log file
  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_errorLogFileName');
  }

  /// Get app version (placeholder - would need to be implemented based on app structure)
  Future<String> _getAppVersion() async {
    // This would typically come from package_info_plus or similar
    return '1.0.0';
  }

  /// Get severity from exception type
  ErrorSeverity _getSeverity(AppException error) {
    if (error is ValidationException) {
      switch (error.severity) {
        case ValidationSeverity.critical:
          return ErrorSeverity.critical;
        case ValidationSeverity.error:
          return ErrorSeverity.error;
        case ValidationSeverity.warning:
          return ErrorSeverity.warning;
        case ValidationSeverity.info:
          return ErrorSeverity.info;
      }
    }
    
    // Default severity based on exception type
    if (error is LogisticsException) {
      return ErrorSeverity.warning; // Non-critical for user experience
    } else if (error is NotificationException) {
      return ErrorSeverity.warning;
    } else {
      return ErrorSeverity.error;
    }
  }

  /// Compare severity levels
  int _compareSeverity(ErrorSeverity a, ErrorSeverity b) {
    const severityOrder = [
      ErrorSeverity.info,
      ErrorSeverity.warning,
      ErrorSeverity.error,
      ErrorSeverity.critical,
    ];
    
    return severityOrder.indexOf(a).compareTo(severityOrder.indexOf(b));
  }
}

/// Error log entry model
class ErrorLogEntry {
  final DateTime timestamp;
  final String errorType;
  final String message;
  final String? code;
  final ErrorSeverity severity;
  final String? stackTrace;
  final Map<String, dynamic>? context;
  final String? userId;
  final String platform;
  final String appVersion;

  ErrorLogEntry({
    required this.timestamp,
    required this.errorType,
    required this.message,
    this.code,
    required this.severity,
    this.stackTrace,
    this.context,
    this.userId,
    required this.platform,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'errorType': errorType,
        'message': message,
        'code': code,
        'severity': severity.toString(),
        'stackTrace': stackTrace,
        'context': context,
        'userId': userId,
        'platform': platform,
        'appVersion': appVersion,
      };

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) => ErrorLogEntry(
        timestamp: DateTime.parse(json['timestamp']),
        errorType: json['errorType'],
        message: json['message'],
        code: json['code'],
        severity: ErrorSeverity.values.firstWhere(
          (e) => e.toString() == json['severity'],
          orElse: () => ErrorSeverity.error,
        ),
        stackTrace: json['stackTrace'],
        context: json['context']?.cast<String, dynamic>(),
        userId: json['userId'],
        platform: json['platform'],
        appVersion: json['appVersion'],
      );
}

/// Error severity levels
enum ErrorSeverity { info, warning, error, critical }

/// Error statistics model
class ErrorStatistics {
  int totalErrors = 0;
  int criticalErrors = 0;
  int errors = 0;
  int warnings = 0;
  int infoMessages = 0;
  Map<String, int> errorsByType = {};

  double get criticalErrorRate => totalErrors > 0 ? criticalErrors / totalErrors : 0.0;
  double get errorRate => totalErrors > 0 ? errors / totalErrors : 0.0;
  double get warningRate => totalErrors > 0 ? warnings / totalErrors : 0.0;
}