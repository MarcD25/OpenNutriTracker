import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/logistics_event_dbo.dart';

import 'package:hive_flutter/hive_flutter.dart';

class LogisticsDebugScreen extends StatefulWidget {
  const LogisticsDebugScreen({Key? key}) : super(key: key);

  @override
  State<LogisticsDebugScreen> createState() => _LogisticsDebugScreenState();
}

class _LogisticsDebugScreenState extends State<LogisticsDebugScreen> {
  List<LogisticsEventDBO> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogisticsData();
  }

  Future<void> _loadLogisticsData() async {
    try {
      // Access the Hive box directly
      final box = await Hive.openBox<LogisticsEventDBO>('LogisticsBox');
      setState(() {
        _events = box.values.toList().reversed.take(100).toList(); // Show last 100 events
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading logistics data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistics Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogisticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No logistics data found'))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(event.eventType),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${event.timestamp}'),
                            if (event.eventData.isNotEmpty)
                              Text('Data: ${event.eventData}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}