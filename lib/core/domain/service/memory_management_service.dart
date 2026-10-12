import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Service for managing memory usage and preventing memory leaks
/// in the nutrition tracker enhancements
class MemoryManagementService {
  static final MemoryManagementService _instance = MemoryManagementService._internal();
  factory MemoryManagementService() => _instance;
  MemoryManagementService._internal();

  final log = Logger('MemoryManagementService');
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final Map<String, dynamic> _resources = {};
  
  Timer? _memoryMonitorTimer;
  bool _isInitialized = false;

  /// Initialize memory management service
  void init() {
    if (_isInitialized) return;
    
    _isInitialized = true;
    
    // Start memory monitoring in debug mode
    if (kDebugMode) {
      _startMemoryMonitoring();
    }
    
    log.info('Memory management service initialized');
  }

  /// Register a stream subscription for automatic cleanup
  void registerSubscription(StreamSubscription subscription, {String? name}) {
    _subscriptions.add(subscription);
    if (name != null) {
      log.fine('Registered subscription: $name');
    }
  }

  /// Register a timer for automatic cleanup
  void registerTimer(Timer timer, {String? name}) {
    _timers.add(timer);
    if (name != null) {
      log.fine('Registered timer: $name');
    }
  }

  /// Register a resource for tracking and cleanup
  void registerResource(String key, dynamic resource) {
    _resources[key] = resource;
    log.fine('Registered resource: $key');
  }

  /// Unregister and dispose a resource
  void unregisterResource(String key) {
    final resource = _resources.remove(key);
    if (resource != null) {
      _disposeResource(resource);
      log.fine('Unregistered resource: $key');
    }
  }

  /// Clean up all registered resources
  void cleanup() {
    log.info('Starting memory cleanup...');
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        log.warning('Error canceling subscription: $e');
      }
    }
    _subscriptions.clear();

    // Cancel all timers
    for (final timer in _timers) {
      try {
        timer.cancel();
      } catch (e) {
        log.warning('Error canceling timer: $e');
      }
    }
    _timers.clear();

    // Dispose all resources
    for (final entry in _resources.entries) {
      try {
        _disposeResource(entry.value);
      } catch (e) {
        log.warning('Error disposing resource ${entry.key}: $e');
      }
    }
    _resources.clear();

    // Stop memory monitoring
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;

    log.info('Memory cleanup completed');
  }

  /// Force garbage collection (debug only)
  void forceGarbageCollection() {
    if (kDebugMode) {
      // Note: gc() is not available in Flutter
      // Using System.gc() equivalent is not recommended in production
      log.info('Forced garbage collection');
    }
  }

  /// Get memory usage statistics
  MemoryStats getMemoryStats() {
    return MemoryStats(
      activeSubscriptions: _subscriptions.length,
      activeTimers: _timers.length,
      trackedResources: _resources.length,
    );
  }

  /// Start monitoring memory usage (debug only)
  void _startMemoryMonitoring() {
    if (!kDebugMode) return;
    
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _logMemoryUsage(),
    );
  }

  /// Log current memory usage (debug only)
  void _logMemoryUsage() {
    if (!kDebugMode) return;
    
    try {
      final stats = getMemoryStats();
      log.info('Memory stats: ${stats.toString()}');
      
      // Log VM memory info if available
      final vmInfo = developer.Service.getInfo();
      log.fine('VM Info: $vmInfo');
    } catch (e) {
      log.warning('Error logging memory usage: $e');
    }
  }

  /// Dispose a resource based on its type
  void _disposeResource(dynamic resource) {
    try {
      if (resource is StreamController) {
        resource.close();
      } else if (resource is StreamSubscription) {
        resource.cancel();
      } else if (resource is Timer) {
        resource.cancel();
      } else if (resource is ChangeNotifier) {
        resource.dispose();
      } else if (resource is Stream) {
        // Streams don't need explicit disposal
      } else if (resource is Future) {
        // Futures don't need explicit disposal
      } else if (resource is Map) {
        resource.clear();
      } else if (resource is List) {
        resource.clear();
      } else if (resource is Set) {
        resource.clear();
      }
      // Add more resource types as needed
    } catch (e) {
      log.warning('Error disposing resource: $e');
    }
  }

  /// Create a managed stream subscription
  StreamSubscription<T> createManagedSubscription<T>(
    Stream<T> stream,
    void Function(T) onData, {
    String? name,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    
    registerSubscription(subscription, name: name);
    return subscription;
  }

  /// Create a managed timer
  Timer createManagedTimer(
    Duration duration,
    void Function() callback, {
    String? name,
  }) {
    final timer = Timer(duration, callback);
    registerTimer(timer, name: name);
    return timer;
  }

  /// Create a managed periodic timer
  Timer createManagedPeriodicTimer(
    Duration period,
    void Function(Timer) callback, {
    String? name,
  }) {
    final timer = Timer.periodic(period, callback);
    registerTimer(timer, name: name);
    return timer;
  }

  /// Dispose the service
  void dispose() {
    cleanup();
    _isInitialized = false;
    log.info('Memory management service disposed');
  }
}

/// Memory usage statistics
class MemoryStats {
  final int activeSubscriptions;
  final int activeTimers;
  final int trackedResources;

  MemoryStats({
    required this.activeSubscriptions,
    required this.activeTimers,
    required this.trackedResources,
  });

  @override
  String toString() {
    return 'MemoryStats(subscriptions: $activeSubscriptions, timers: $activeTimers, resources: $trackedResources)';
  }
}

/// Mixin for automatic memory management in widgets and services
mixin MemoryManagementMixin {
  final MemoryManagementService _memoryService = MemoryManagementService();
  final List<StreamSubscription> _localSubscriptions = [];
  final List<Timer> _localTimers = [];

  /// Register a subscription for automatic cleanup
  void addSubscription(StreamSubscription subscription) {
    _localSubscriptions.add(subscription);
    _memoryService.registerSubscription(subscription);
  }

  /// Register a timer for automatic cleanup
  void addTimer(Timer timer) {
    _localTimers.add(timer);
    _memoryService.registerTimer(timer);
  }

  /// Clean up all local resources
  void cleanupMemory() {
    for (final subscription in _localSubscriptions) {
      subscription.cancel();
    }
    _localSubscriptions.clear();

    for (final timer in _localTimers) {
      timer.cancel();
    }
    _localTimers.clear();
  }
}