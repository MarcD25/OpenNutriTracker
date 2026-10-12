import 'dart:async';

/// Service for caching frequently calculated values to improve performance
class CalculationCacheService {
  static final CalculationCacheService _instance = CalculationCacheService._internal();
  factory CalculationCacheService() => _instance;
  CalculationCacheService._internal();

  final Map<String, _CacheEntry> _cache = {};
  static const int _maxCacheSize = 100;
  static const Duration _defaultTTL = Duration(minutes: 15);
  
  Timer? _cleanupTimer;

  void init() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) => _cleanup());
  }

  /// Cache a calculated value with optional TTL
  void put<T>(String key, T value, {Duration? ttl}) {
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _cache.remove(oldestKey);
    }

    _cache[key] = _CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );
  }

  /// Get a cached value, returns null if not found or expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().difference(entry.timestamp) > entry.ttl) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// Get or calculate a value, caching the result
  Future<T> getOrCalculate<T>(
    String key,
    Future<T> Function() calculator, {
    Duration? ttl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final calculated = await calculator();
    put(key, calculated, ttl: ttl);
    return calculated;
  }

  /// Get or calculate a synchronous value, caching the result
  T getOrCalculateSync<T>(
    String key,
    T Function() calculator, {
    Duration? ttl,
  }) {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final calculated = calculator();
    put(key, calculated, ttl: ttl);
    return calculated;
  }

  /// Check if a key exists and is not expired
  bool contains(String key) {
    return get(key) != null;
  }

  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cached values
  void clear() {
    _cache.clear();
  }

  /// Clear cached values matching a pattern
  void clearByPattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Get cache statistics
  CacheStats getStats() {
    final now = DateTime.now();
    final expired = _cache.values
        .where((entry) => now.difference(entry.timestamp) > entry.ttl)
        .length;
    
    return CacheStats(
      totalEntries: _cache.length,
      expiredEntries: expired,
      activeEntries: _cache.length - expired,
      hitRate: 0.0, // Would need to track hits/misses for accurate rate
    );
  }

  /// Clean up expired entries
  void _cleanup() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.difference(entry.value.timestamp) > entry.value.ttl)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;
  final Duration ttl;

  _CacheEntry({
    required this.value,
    required this.timestamp,
    required this.ttl,
  });
}

class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeEntries;
  final double hitRate;

  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeEntries,
    required this.hitRate,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, active: $activeEntries, expired: $expiredEntries, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}