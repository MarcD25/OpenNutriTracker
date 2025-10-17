import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/service/calculation_cache_service.dart';
import 'package:opennutritracker/core/domain/service/memory_management_service.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';

/// Widget for monitoring performance optimizations in debug mode
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;

  const PerformanceMonitorWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  bool _showMonitor = false;
  final _cacheService = CalculationCacheService();
  final _memoryService = MemoryManagementService();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showMonitor) _buildMonitorOverlay(),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      top: 50,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: () => setState(() => _showMonitor = !_showMonitor),
        backgroundColor: Colors.orange,
        child: Icon(_showMonitor ? Icons.close : Icons.speed),
      ),
    );
  }

  Widget _buildMonitorOverlay() {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance Monitor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildCacheStats(),
            const SizedBox(height: 8),
            _buildMemoryStats(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStats() {
    final cacheStats = _cacheService.getStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cache Statistics:',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Total Entries: ${cacheStats.totalEntries}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          'Active Entries: ${cacheStats.activeEntries}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          'Expired Entries: ${cacheStats.expiredEntries}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMemoryStats() {
    final memoryStats = _memoryService.getMemoryStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Statistics:',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Subscriptions: ${memoryStats.activeSubscriptions}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          'Timers: ${memoryStats.activeTimers}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          'Resources: ${memoryStats.trackedResources}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _cacheService.clear();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text(
              'Clear Cache',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _memoryService.forceGarbageCollection();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text(
              'Force GC',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}

/// Debug overlay for showing performance metrics
class PerformanceDebugOverlay extends StatelessWidget {
  const PerformanceDebugOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cache: ${EnhancedCalorieGoalCalc.getCacheStats()}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Memory: ${MemoryManagementService().getMemoryStats()}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}