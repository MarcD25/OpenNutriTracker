import 'package:flutter/material.dart';
import 'package:opennutritracker/core/services/notification_manager.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// Widget for managing notification settings
class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    try {
      final enabled = await NotificationManager().areNotificationsEnabled();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permissions
      final granted = await NotificationManager().requestAllPermissions();
      if (mounted) {
        setState(() {
          _notificationsEnabled = granted;
        });
        
        if (!granted) {
          _showPermissionDialog();
        }
      }
    } else {
      // Disable notifications
      await NotificationManager().cancelAllNotifications();
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text('To receive weight check-in reminders, please enable notifications in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        leading: Icon(Icons.notifications),
        title: Text('Notifications'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('Notifications'),
      subtitle: Text(
        _notificationsEnabled
            ? 'Notifications are enabled'
            : 'Notifications are disabled',
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
      ),
    );
  }
}