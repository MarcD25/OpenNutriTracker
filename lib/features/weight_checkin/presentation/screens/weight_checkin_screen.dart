import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/weight_checkin/presentation/bloc/weight_checkin_bloc.dart';
import 'package:opennutritracker/features/weight_checkin/presentation/widgets/weight_checkin_card.dart';
import 'package:opennutritracker/features/weight_checkin/presentation/widgets/weight_progress_chart.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

class WeightCheckinScreen extends StatelessWidget {
  final String weightUnit;

  const WeightCheckinScreen({
    Key? key,
    this.weightUnit = 'kg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeightCheckinBloc>(
      create: (context) => locator<WeightCheckinBloc>(),
      child: _WeightCheckinScreenContent(weightUnit: weightUnit),
    );
  }
}

class _WeightCheckinScreenContent extends StatefulWidget {
  final String weightUnit;

  const _WeightCheckinScreenContent({
    Key? key,
    required this.weightUnit,
  }) : super(key: key);

  @override
  State<_WeightCheckinScreenContent> createState() => _WeightCheckinScreenContentState();
}

class _WeightCheckinScreenContentState extends State<_WeightCheckinScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    context.read<WeightCheckinBloc>().add(const LoadWeightCheckinData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Check-in'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.monitor_weight),
              text: 'Check-in',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Progress',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCheckinTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildCheckinTab() {
    return BlocConsumer<WeightCheckinBloc, WeightCheckinState>(
      listener: (context, state) {
        if (state is WeightCheckinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is WeightEntryRecorded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weight recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is WeightCheckinLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WeightCheckinLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                WeightCheckinCard(
                  onWeightSubmitted: (weight, notes) {
                    context.read<WeightCheckinBloc>().add(
                          RecordWeightEntry(
                            weight: weight,
                            notes: notes,
                          ),
                        );
                  },
                  lastEntry: state.latestEntry,
                  trend: state.trend,
                  weightUnit: widget.weightUnit,
                ),
                if (state.weightHistory.isNotEmpty) ...[
                  _buildRecentEntries(state.weightHistory.take(5).toList()),
                ],
              ],
            ),
          );
        }

        return const Center(
          child: Text('Failed to load weight check-in data'),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return BlocBuilder<WeightCheckinBloc, WeightCheckinState>(
      builder: (context, state) {
        if (state is WeightCheckinLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WeightCheckinLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                WeightProgressChart(
                  weightHistory: state.weightHistory,
                  trend: state.trend,
                  weightUnit: widget.weightUnit,
                ),
                if (state.weightHistory.isNotEmpty) ...[
                  _buildStatistics(state),
                  _buildFullHistory(state.weightHistory),
                ],
              ],
            ),
          );
        }

        return const Center(
          child: Text('No progress data available'),
        );
      },
    );
  }

  Widget _buildRecentEntries(List<WeightEntryEntity> entries) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) => _buildEntryTile(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(WeightEntryEntity entry) {
    final weight = widget.weightUnit == 'lbs' ? entry.weightLbs : entry.weightKG;
    final formattedWeight = '${weight.toStringAsFixed(1)} ${widget.weightUnit}';
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.monitor_weight_outlined),
      title: Text(formattedWeight),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(entry.timestamp)),
          if (entry.notes != null && entry.notes!.isNotEmpty)
            Text(
              entry.notes!,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(entry),
      ),
    );
  }

  Widget _buildStatistics(WeightCheckinLoaded state) {
    if (state.weightHistory.isEmpty) return const SizedBox.shrink();

    final entries = state.weightHistory;
    final weights = entries.map((e) => 
        widget.weightUnit == 'lbs' ? e.weightLbs : e.weightKG).toList();
    
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Lowest',
                    '${minWeight.toStringAsFixed(1)} ${widget.weightUnit}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Highest',
                    '${maxWeight.toStringAsFixed(1)} ${widget.weightUnit}',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    '${avgWeight.toStringAsFixed(1)} ${widget.weightUnit}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHistory(List<WeightEntryEntity> entries) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'All Entries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entries.length} total',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => _buildEntryTile(entries[index]),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<WeightCheckinBloc, WeightCheckinState>(
        builder: (context, state) {
          CheckinFrequency currentFrequency = CheckinFrequency.weekly;
          if (state is WeightCheckinLoaded) {
            currentFrequency = state.checkinFrequency;
          }

          return AlertDialog(
            title: const Text('Check-in Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Check-in Frequency:'),
                const SizedBox(height: 8),
                ...CheckinFrequency.values.map((frequency) {
                  return RadioListTile<CheckinFrequency>(
                    title: Text(_getFrequencyDisplayName(frequency)),
                    value: frequency,
                    groupValue: currentFrequency,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<WeightCheckinBloc>().add(
                              SetCheckinFrequency(value),
                            );
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(WeightEntryEntity entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete this weight entry from ${_formatDate(entry.timestamp)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WeightCheckinBloc>().add(
                    DeleteWeightEntry(entry.id),
                  );
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getFrequencyDisplayName(CheckinFrequency frequency) {
    switch (frequency) {
      case CheckinFrequency.daily:
        return 'Daily';
      case CheckinFrequency.weekly:
        return 'Weekly';
      case CheckinFrequency.biweekly:
        return 'Bi-weekly';
      case CheckinFrequency.monthly:
        return 'Monthly';
    }
  }
}