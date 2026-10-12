import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';

/// Debug helper widget for weight check-in functionality
/// This can be temporarily added to any screen for testing
class WeightCheckinDebugHelper extends StatelessWidget {
  const WeightCheckinDebugHelper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.orange.withOpacity(0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Weight Check-in Debug Helper',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _addSampleData(context),
                child: const Text('Add Sample Data'),
              ),
              ElevatedButton(
                onPressed: () => _clearAllData(context),
                child: const Text('Clear All Data'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _setWeeklyFrequency(context),
                child: const Text('Set Weekly'),
              ),
              ElevatedButton(
                onPressed: () => _setDailyFrequency(context),
                child: const Text('Set Daily'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showCurrentData(context),
            child: const Text('Show Current Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleData(BuildContext context) async {
    try {
      final usecase = locator<WeightCheckinUsecase>();
      await usecase.addSampleWeightData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample weight data added! Check the calendar for highlights.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      final usecase = locator<WeightCheckinUsecase>();
      final history = await usecase.getAllWeightHistory();
      
      for (final entry in history) {
        await usecase.deleteWeightEntry(entry.id);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All weight data cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setWeeklyFrequency(BuildContext context) async {
    try {
      final usecase = locator<WeightCheckinUsecase>();
      await usecase.setCheckinFrequency(CheckinFrequency.weekly);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in frequency set to weekly!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set frequency: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setDailyFrequency(BuildContext context) async {
    try {
      final usecase = locator<WeightCheckinUsecase>();
      await usecase.setCheckinFrequency(CheckinFrequency.daily);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in frequency set to daily!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set frequency: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCurrentData(BuildContext context) async {
    try {
      final usecase = locator<WeightCheckinUsecase>();
      final history = await usecase.getAllWeightHistory();
      final frequency = await usecase.getCheckinFrequency();
      final nextCheckin = await usecase.getNextCheckinDate();
      
      final message = '''
Current Data:
• Frequency: ${frequency.name}
• History entries: ${history.length}
• Next check-in: ${nextCheckin?.toString() ?? 'Not set'}
• Latest entry: ${history.isNotEmpty ? '${history.first.weightKG}kg on ${history.first.timestamp.day}/${history.first.timestamp.month}' : 'None'}
      ''';
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Weight Check-in Data'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}