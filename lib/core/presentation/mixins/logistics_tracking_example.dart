// Example of how to use LogisticsTrackingMixin in your screens
// This file is for documentation purposes only

import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/core/presentation/mixins/logistics_tracking_mixin.dart';

/// Example screen showing how to integrate LogisticsTrackingMixin
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> with LogisticsTrackingMixin {
  
  @override
  void initState() {
    super.initState();
    // Track when the screen is initialized
    trackScreenView('ExampleScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Track button press
              trackButtonPress('save_button', 'ExampleScreen');
              
              // Simulate saving data
              _saveData();
            },
            child: const Text('Save Data'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track navigation
              trackNavigation('ExampleScreen', 'SettingsScreen');
              
              // Navigate to settings
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Go to Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track meal logging
              trackMealLogged('breakfast', 3, 450.0);
              
              // Simulate meal logging
              _logMeal();
            },
            child: const Text('Log Meal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track exercise logging
              trackExerciseLogged('running', const Duration(minutes: 30), 250.0);
              
              // Simulate exercise logging
              _logExercise();
            },
            child: const Text('Log Exercise'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track weight checkin
              trackWeightCheckin(70.5, 'kg');
              
              // Simulate weight checkin
              _logWeight();
            },
            child: const Text('Log Weight'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track settings change
              trackSettingsChanged('theme', 'light', 'dark');
              
              // Simulate settings change
              _changeSettings();
            },
            child: const Text('Change Theme'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track goal update
              trackGoalUpdated('calorie_goal', 2000, 2200);
              
              // Simulate goal update
              _updateGoal();
            },
            child: const Text('Update Goal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track search action
              trackSearch('chicken breast', 'ExampleScreen', 15);
              
              // Simulate search
              _performSearch();
            },
            child: const Text('Search Food'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track form submission
              trackFormSubmission(
                'user_profile_form', 
                'ExampleScreen',
                isSuccessful: true,
                formData: {'name': 'John', 'age': 30},
              );
              
              // Simulate form submission
              _submitForm();
            },
            child: const Text('Submit Form'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track error
              trackError(
                'network_error', 
                'Failed to connect to server', 
                'ExampleScreen',
                stackTrace: 'Stack trace here...',
              );
              
              // Simulate error handling
              _handleError();
            },
            child: const Text('Simulate Error'),
          ),
          ElevatedButton(
            onPressed: () {
              // Track performance
              final stopwatch = Stopwatch()..start();
              
              // Simulate some operation
              _performOperation();
              
              stopwatch.stop();
              trackPerformance(
                'data_processing', 
                stopwatch.elapsed, 
                'ExampleScreen',
                isSuccessful: true,
              );
            },
            child: const Text('Track Performance'),
          ),
        ],
      ),
    );
  }

  void _saveData() {
    // Simulate data saving
    print('Data saved');
  }

  void _logMeal() {
    // Simulate meal logging
    print('Meal logged');
  }

  void _logExercise() {
    // Simulate exercise logging
    print('Exercise logged');
  }

  void _logWeight() {
    // Simulate weight logging
    print('Weight logged');
  }

  void _changeSettings() {
    // Simulate settings change
    print('Settings changed');
  }

  void _updateGoal() {
    // Simulate goal update
    print('Goal updated');
  }

  void _performSearch() {
    // Simulate search
    print('Search performed');
  }

  void _submitForm() {
    // Simulate form submission
    print('Form submitted');
  }

  void _handleError() {
    // Simulate error handling
    print('Error handled');
  }

  void _performOperation() {
    // Simulate some time-consuming operation
    for (int i = 0; i < 1000000; i++) {
      // Do some work
    }
  }
}

/// Example of using logistics tracking with custom actions
class CustomTrackingExample extends StatefulWidget {
  const CustomTrackingExample({super.key});

  @override
  State<CustomTrackingExample> createState() => _CustomTrackingExampleState();
}

class _CustomTrackingExampleState extends State<CustomTrackingExample> with LogisticsTrackingMixin {
  
  void _trackCustomAction() {
    // Track custom user action
    trackAction(
      LogisticsEventType.userAction,
      {
        'custom_action': 'special_feature_used',
        'feature_name': 'advanced_calculator',
        'user_input_count': 5,
        'calculation_result': 42.0,
      },
      metadata: {
        'feature_category': 'advanced_tools',
        'user_experience_level': 'intermediate',
      },
    );
  }

  void _trackChatInteraction() {
    // Track chat interaction
    trackChatInteraction(
      'What should I eat for breakfast?',
      'I recommend oatmeal with fruits and nuts.',
      const Duration(milliseconds: 1500),
      additionalData: {
        'chat_session_id': 'session_123',
        'user_satisfaction': 'high',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Tracking Example'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _trackCustomAction,
            child: const Text('Track Custom Action'),
          ),
          ElevatedButton(
            onPressed: _trackChatInteraction,
            child: const Text('Track Chat Interaction'),
          ),
        ],
      ),
    );
  }
}

/// Example of tracking app lifecycle events
class AppLifecycleTrackingExample extends StatefulWidget {
  const AppLifecycleTrackingExample({super.key});

  @override
  State<AppLifecycleTrackingExample> createState() => _AppLifecycleTrackingExampleState();
}

class _AppLifecycleTrackingExampleState extends State<AppLifecycleTrackingExample> 
    with LogisticsTrackingMixin, WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Track app launched
    trackAppLaunched(additionalData: {
      'launch_source': 'user_tap',
      'previous_session_duration': '15_minutes',
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        trackAction(
          LogisticsEventType.appLaunched,
          {
            'lifecycle_state': 'resumed',
            'timestamp': DateTime.now().toIso8601String(),
          },
          metadata: {
            'app_lifecycle': true,
            'session_type': 'resume',
          },
        );
        break;
      case AppLifecycleState.paused:
        trackAction(
          LogisticsEventType.userAction,
          {
            'lifecycle_state': 'paused',
            'timestamp': DateTime.now().toIso8601String(),
          },
          metadata: {
            'app_lifecycle': true,
            'session_type': 'pause',
          },
        );
        break;
      case AppLifecycleState.detached:
        trackAction(
          LogisticsEventType.userAction,
          {
            'lifecycle_state': 'detached',
            'timestamp': DateTime.now().toIso8601String(),
          },
          metadata: {
            'app_lifecycle': true,
            'session_type': 'close',
          },
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lifecycle Tracking'),
      ),
      body: const Center(
        child: Text('This screen tracks app lifecycle events automatically.'),
      ),
    );
  }
}