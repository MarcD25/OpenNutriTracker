import 'package:flutter/material.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/core/domain/service/memory_management_service.dart';

class WeightProgressChart extends StatefulWidget {
  final List<WeightEntryEntity> weightHistory;
  final WeightTrend? trend;
  final String weightUnit;
  final int daysToShow;
  final int maxDataPoints; // Performance optimization: limit data points

  const WeightProgressChart({
    Key? key,
    required this.weightHistory,
    this.trend,
    this.weightUnit = 'kg',
    this.daysToShow = 30,
    this.maxDataPoints = 100, // Limit for performance
  }) : super(key: key);

  @override
  State<WeightProgressChart> createState() => _WeightProgressChartState();
}

class _WeightProgressChartState extends State<WeightProgressChart> 
    with AutomaticKeepAliveClientMixin, MemoryManagementMixin {
  
  List<WeightEntryEntity>? _cachedOptimizedData;
  String? _cacheKey;
  
  @override
  bool get wantKeepAlive => true; // Keep widget alive for performance

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (widget.weightHistory.isEmpty) {
      return _buildEmptyState();
    }

    final optimizedData = _getOptimizedData();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(optimizedData),
            const SizedBox(height: 16),
            _buildChart(optimizedData),
            if (widget.trend != null) ...[
              const SizedBox(height: 16),
              _buildTrendSummary(),
            ],
          ],
        ),
      ),
    );
  }

  List<WeightEntryEntity> _getOptimizedData() {
    // Create cache key based on data characteristics
    final newCacheKey = '${widget.weightHistory.length}_${widget.daysToShow}_${widget.maxDataPoints}';
    
    // Return cached data if available and valid
    if (_cachedOptimizedData != null && _cacheKey == newCacheKey) {
      return _cachedOptimizedData!;
    }
    
    // Optimize data for rendering
    final optimizedData = _optimizeDataForRendering(widget.weightHistory);
    
    // Cache the result
    _cachedOptimizedData = optimizedData;
    _cacheKey = newCacheKey;
    
    return optimizedData;
  }

  List<WeightEntryEntity> _optimizeDataForRendering(List<WeightEntryEntity> data) {
    if (data.length <= widget.maxDataPoints) {
      return data;
    }

    // Sort by timestamp
    final sortedData = List<WeightEntryEntity>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Use data decimation algorithm to reduce points while preserving shape
    return _decimateData(sortedData, widget.maxDataPoints);
  }

  List<WeightEntryEntity> _decimateData(List<WeightEntryEntity> data, int maxPoints) {
    if (data.length <= maxPoints) return data;

    final result = <WeightEntryEntity>[];
    final step = data.length / maxPoints;
    
    // Always include first and last points
    result.add(data.first);
    
    // Sample points at regular intervals
    for (int i = 1; i < maxPoints - 1; i++) {
      final index = (i * step).round();
      if (index < data.length) {
        result.add(data[index]);
      }
    }
    
    // Always include last point
    if (data.length > 1) {
      result.add(data.last);
    }
    
    return result;
  }

  Widget _buildHeader(List<WeightEntryEntity> optimizedData) {
    return Row(
      children: [
        const Icon(Icons.trending_up, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          'Weight Progress (${widget.daysToShow} days)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.weightHistory.length} entries',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (optimizedData.length != widget.weightHistory.length)
              Text(
                '${optimizedData.length} shown',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(List<WeightEntryEntity> optimizedData) {
    // Optimized chart implementation using CustomPaint with caching
    return Container(
      height: 200,
      width: double.infinity,
      child: RepaintBoundary( // Optimize repaints
        child: CustomPaint(
          painter: OptimizedWeightChartPainter(
            weightHistory: optimizedData,
            weightUnit: widget.weightUnit,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSummary() {
    final trend = widget.trend!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Summary',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTrendStat(
                  'Direction',
                  trend.directionText,
                  _getTrendColor(trend.trendDirection),
                ),
              ),
              Expanded(
                child: _buildTrendStat(
                  'Weekly Change',
                  trend.weeklyChangeText,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTrendStat(
                  'Total Change',
                  trend.totalChangeText,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildTrendStat(
                  'Confidence',
                  trend.confidenceText,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Weight Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your weight to see progress charts and trends.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(WeightTrendDirection direction) {
    switch (direction) {
      case WeightTrendDirection.increasing:
        return Colors.red;
      case WeightTrendDirection.decreasing:
        return Colors.green;
      case WeightTrendDirection.stable:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    // Clear cached data to free memory
    _cachedOptimizedData?.clear();
    _cachedOptimizedData = null;
    _cacheKey = null;
    
    // Clean up memory resources
    cleanupMemory();
    
    super.dispose();
  }
}

class OptimizedWeightChartPainter extends CustomPainter {
  final List<WeightEntryEntity> weightHistory;
  final String weightUnit;
  
  // Cache for expensive calculations
  static final Map<String, _ChartCache> _cache = {};
  static const int _maxCacheSize = 10;

  OptimizedWeightChartPainter({
    required this.weightHistory,
    required this.weightUnit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weightHistory.isEmpty) return;

    // Create cache key
    final cacheKey = _createCacheKey(size);
    
    // Check cache first
    final cachedData = _cache[cacheKey];
    if (cachedData != null && cachedData.isValid(weightHistory)) {
      _paintFromCache(canvas, cachedData);
      return;
    }

    // Calculate and cache expensive operations
    final chartData = _calculateChartData(size);
    _updateCache(cacheKey, chartData);
    
    // Paint the chart
    _paintChart(canvas, size, chartData);
  }

  String _createCacheKey(Size size) {
    return '${weightHistory.length}_${size.width}_${size.height}_$weightUnit';
  }

  _ChartCache _calculateChartData(Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Sort entries by timestamp (already optimized data)
    final sortedEntries = List<WeightEntryEntity>.from(weightHistory)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate bounds
    final weights = sortedEntries.map((e) => 
        weightUnit == 'lbs' ? e.weightLbs : e.weightKG).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    
    // Add some padding to the range
    final weightRange = maxWeight - minWeight;
    final paddedMin = minWeight - (weightRange * 0.1);
    final paddedMax = maxWeight + (weightRange * 0.1);
    final paddedRange = paddedMax - paddedMin;

    // Calculate time bounds
    final startTime = sortedEntries.first.timestamp;
    final endTime = sortedEntries.last.timestamp;
    final timeRange = endTime.difference(startTime).inMilliseconds;

    // Pre-calculate all points
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final weight = weightUnit == 'lbs' ? entry.weightLbs : entry.weightKG;
      
      final x = timeRange > 0 
          ? (entry.timestamp.difference(startTime).inMilliseconds / timeRange) * size.width
          : size.width / 2;
      final y = paddedRange > 0
          ? size.height - ((weight - paddedMin) / paddedRange) * size.height
          : size.height / 2;

      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return _ChartCache(
      path: path,
      points: points,
      paddedMin: paddedMin,
      paddedMax: paddedMax,
      paint: paint,
      pointPaint: pointPaint,
      dataHash: weightHistory.hashCode,
      timestamp: DateTime.now(),
    );
  }

  void _updateCache(String key, _ChartCache data) {
    // Limit cache size
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[key] = data;
  }

  void _paintFromCache(Canvas canvas, _ChartCache cache) {
    // Draw from cached data
    canvas.drawPath(cache.path, cache.paint);
    for (final point in cache.points) {
      canvas.drawCircle(point, 4.0, cache.pointPaint);
    }
  }

  void _paintChart(Canvas canvas, Size size, _ChartCache chartData) {
    // Draw grid lines
    _drawGrid(canvas, size, chartData.paddedMin, chartData.paddedMax);

    // Draw the weight line
    canvas.drawPath(chartData.path, chartData.paint);

    // Draw points
    for (final point in chartData.points) {
      canvas.drawCircle(point, 4.0, chartData.pointPaint);
    }

    // Draw weight labels
    _drawWeightLabels(canvas, size, chartData.paddedMin, chartData.paddedMax);
  }

  void _drawGrid(Canvas canvas, Size size, double minWeight, double maxWeight) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = (i / 4) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  void _drawWeightLabels(Canvas canvas, Size size, double minWeight, double maxWeight) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw weight labels on the left
    for (int i = 0; i <= 4; i++) {
      final weight = minWeight + ((maxWeight - minWeight) * (4 - i) / 4);
      final y = (i / 4) * size.height;

      textPainter.text = TextSpan(
        text: weight.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width - 4, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant OptimizedWeightChartPainter oldDelegate) {
    // Only repaint if data actually changed
    return weightHistory.hashCode != oldDelegate.weightHistory.hashCode ||
           weightUnit != oldDelegate.weightUnit;
  }
}

// Cache class for expensive chart calculations
class _ChartCache {
  final Path path;
  final List<Offset> points;
  final double paddedMin;
  final double paddedMax;
  final Paint paint;
  final Paint pointPaint;
  final int dataHash;
  final DateTime timestamp;
  
  _ChartCache({
    required this.path,
    required this.points,
    required this.paddedMin,
    required this.paddedMax,
    required this.paint,
    required this.pointPaint,
    required this.dataHash,
    required this.timestamp,
  });
  
  bool isValid(List<WeightEntryEntity> currentData) {
    // Cache is valid if data hasn't changed and it's not too old
    final isDataSame = dataHash == currentData.hashCode;
    final isNotExpired = DateTime.now().difference(timestamp).inMinutes < 30;
    return isDataSame && isNotExpired;
  }
}