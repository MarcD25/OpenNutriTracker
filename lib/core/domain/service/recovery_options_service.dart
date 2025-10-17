import 'package:flutter/material.dart';
import '../exception/app_exception.dart';
import 'error_logging_service.dart';
import 'graceful_degradation_service.dart';

/// Service for providing user-friendly recovery options
class RecoveryOptionsService {
  static final RecoveryOptionsService _instance = RecoveryOptionsService._internal();
  factory RecoveryOptionsService() => _instance;
  RecoveryOptionsService._internal();

  final ErrorLoggingService _loggingService = ErrorLoggingService();
  final GracefulDegradationService _degradationService = GracefulDegradationService();

  /// Get recovery options for a specific error
  List<RecoveryOption> getRecoveryOptions(AppException error) {
    if (error is ValidationException) {
      return _getValidationRecoveryOptions(error);
    } else if (error is LogisticsException) {
      return _getLogisticsRecoveryOptions(error);
    } else if (error is WeightCheckinException) {
      return _getWeightCheckinRecoveryOptions(error);
    } else if (error is CalorieCalculationException) {
      return _getCalorieCalculationRecoveryOptions(error);
    } else if (error is NotificationException) {
      return _getNotificationRecoveryOptions(error);
    }
    
    return _getGenericRecoveryOptions(error);
  }

  /// Show recovery options dialog
  void showRecoveryDialog(
    BuildContext context,
    AppException error, {
    VoidCallback? onDismiss,
  }) {
    final options = getRecoveryOptions(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recovery Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Something went wrong: ${error.message}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'What would you like to do?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...options.map((option) => ListTile(
              leading: Icon(option.icon),
              title: Text(option.title),
              subtitle: option.description != null ? Text(option.description!) : null,
              onTap: () {
                Navigator.of(context).pop();
                option.action();
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Get validation-specific recovery options
  List<RecoveryOption> _getValidationRecoveryOptions(ValidationException error) {
    final options = <RecoveryOption>[];

    if (error.correctedValue != null) {
      options.add(RecoveryOption(
        title: 'Use Suggested Value',
        description: 'Use the corrected value: ${error.correctedValue}',
        icon: Icons.auto_fix_high,
        action: () {
          // This would be handled by the calling widget
        },
      ));
    }

    if (error.issues.contains(ValidationIssue.unrealisticCalories)) {
      options.add(RecoveryOption(
        title: 'Recalculate Automatically',
        description: 'Let the app estimate calories based on your activity',
        icon: Icons.calculate,
        action: () {
          // Trigger automatic calculation
        },
      ));
    }

    options.add(RecoveryOption(
      title: 'Edit Input',
      description: 'Go back and modify your input',
      icon: Icons.edit,
      action: () {
        // This would be handled by the calling widget
      },
    ));

    options.add(RecoveryOption(
      title: 'Skip Validation',
      description: 'Continue with the original value',
      icon: Icons.skip_next,
      action: () {
        // Continue without validation
      },
    ));

    return options;
  }

  /// Get logistics-specific recovery options
  List<RecoveryOption> _getLogisticsRecoveryOptions(LogisticsException error) {
    return [
      RecoveryOption(
        title: 'Continue Without Tracking',
        description: 'The app will work normally, but this action won\'t be tracked',
        icon: Icons.play_arrow,
        action: () {
          _degradationService.disableFeature('logistics_tracking');
        },
      ),
      RecoveryOption(
        title: 'Retry Tracking',
        description: 'Try to track this action again',
        icon: Icons.refresh,
        action: () {
          _degradationService.resetFeatureStatus('logistics_tracking');
        },
      ),
    ];
  }

  /// Get weight check-in recovery options
  List<RecoveryOption> _getWeightCheckinRecoveryOptions(WeightCheckinException error) {
    return [
      RecoveryOption(
        title: 'Enter Weight Manually',
        description: 'Skip automated features and enter weight directly',
        icon: Icons.edit,
        action: () {
          // This would be handled by the calling widget
        },
      ),
      RecoveryOption(
        title: 'Skip This Check-in',
        description: 'Continue without recording weight today',
        icon: Icons.skip_next,
        action: () {
          // Skip weight check-in
        },
      ),
      RecoveryOption(
        title: 'Check Settings',
        description: 'Review weight check-in settings',
        icon: Icons.settings,
        action: () {
          // Navigate to settings
        },
      ),
      RecoveryOption(
        title: 'Retry',
        description: 'Try the weight check-in process again',
        icon: Icons.refresh,
        action: () {
          _degradationService.resetFeatureStatus('weight_checkin');
        },
      ),
    ];
  }

  /// Get calorie calculation recovery options
  List<RecoveryOption> _getCalorieCalculationRecoveryOptions(CalorieCalculationException error) {
    return [
      RecoveryOption(
        title: 'Use Default Values',
        description: 'Continue with standard calorie calculations',
        icon: Icons.restore,
        action: () {
          // Use fallback calculation
        },
      ),
      RecoveryOption(
        title: 'Update Profile',
        description: 'Check and update your profile information',
        icon: Icons.person,
        action: () {
          // Navigate to profile
        },
      ),
      RecoveryOption(
        title: 'Recalculate',
        description: 'Try calculating calories again',
        icon: Icons.refresh,
        action: () {
          _degradationService.resetFeatureStatus('calorie_calculation');
        },
      ),
    ];
  }

  /// Get notification recovery options
  List<RecoveryOption> _getNotificationRecoveryOptions(NotificationException error) {
    return [
      RecoveryOption(
        title: 'Check Device Settings',
        description: 'Open device notification settings',
        icon: Icons.settings,
        action: () {
          // This would open device settings
        },
      ),
      RecoveryOption(
        title: 'Continue Without Notifications',
        description: 'Use the app without notification reminders',
        icon: Icons.notifications_off,
        action: () {
          _degradationService.disableFeature('notifications');
        },
      ),
      RecoveryOption(
        title: 'Retry',
        description: 'Try setting up notifications again',
        icon: Icons.refresh,
        action: () {
          _degradationService.resetFeatureStatus('notifications');
        },
      ),
    ];
  }

  /// Get generic recovery options
  List<RecoveryOption> _getGenericRecoveryOptions(AppException error) {
    return [
      RecoveryOption(
        title: 'Retry',
        description: 'Try the operation again',
        icon: Icons.refresh,
        action: () {
          // This would be handled by the calling widget
        },
      ),
      RecoveryOption(
        title: 'Continue',
        description: 'Continue using the app normally',
        icon: Icons.play_arrow,
        action: () {
          // Continue with degraded functionality
        },
      ),
      RecoveryOption(
        title: 'Report Issue',
        description: 'Send error report to help improve the app',
        icon: Icons.bug_report,
        action: () {
          _reportIssue(error);
        },
      ),
    ];
  }

  /// Report issue for debugging
  void _reportIssue(AppException error) {
    _loggingService.logCustomError(
      'User reported issue: ${error.message}',
      errorType: 'UserReported',
      context: {
        'originalError': error.toString(),
        'userAction': 'reported_issue',
      },
    );
  }

  /// Create a recovery action button
  Widget createRecoveryButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Create a recovery action card
  Widget createRecoveryCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

/// Recovery option model
class RecoveryOption {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback action;

  RecoveryOption({
    required this.title,
    this.description,
    required this.icon,
    required this.action,
  });
}