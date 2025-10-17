import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/app_banner_version.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/presentation/mixins/logistics_tracking_mixin.dart';
import 'package:opennutritracker/core/utils/app_const.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/theme_mode_provider.dart';
import 'package:opennutritracker/core/utils/url_const.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/export_import_dialog.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/chat_settings_dialog.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/notification_settings_widget.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/calorie_adjustment_widget.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/calculations_dialog.dart';
import 'package:opennutritracker/features/debug/logistics_debug_screen.dart';
import 'package:opennutritracker/features/debug/logistics_export_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with LogisticsTrackingMixin {
  late SettingsBloc _settingsBloc;
  late ProfileBloc _profileBloc;
  late HomeBloc _homeBloc;
  late DiaryBloc _diaryBloc;
  late CalendarDayBloc _calendarDayBloc;
  late WeightCheckinUsecase _weightCheckinUsecase;

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    _weightCheckinUsecase = locator<WeightCheckinUsecase>();
    
    // Track screen view
    trackScreenView('SettingsScreen', additionalData: {
      'screen_category': 'configuration',
      'is_initial_load': true,
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsLabel),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: _settingsBloc,
        builder: (context, state) {
          if (state is SettingsInitial) {
            _settingsBloc.add(LoadSettingsEvent());
          } else if (state is SettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoadedState) {
            return ListView(
              children: [
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.ac_unit_outlined),
                  title: Text(S.of(context).settingsUnitsLabel),
                  onTap: () {
                    trackButtonPress('settings_units', 'SettingsScreen');
                    _showUnitsDialog(context, state.usesImperialUnits);
                  },
                ),
                CalorieAdjustmentWidget(
                  settingsBloc: _settingsBloc,
                  profileBloc: _profileBloc,
                  homeBloc: _homeBloc,
                  diaryBloc: _diaryBloc,
                  calendarDayBloc: _calendarDayBloc,
                ),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text(S.of(context).settingsCalculationsLabel),
                  onTap: () {
                    trackButtonPress('settings_calculations', 'SettingsScreen');
                    _showCalculationsDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_medium_outlined),
                  title: Text(S.of(context).settingsThemeLabel),
                  onTap: () {
                    trackButtonPress('settings_theme', 'SettingsScreen');
                    _showThemeDialog(context, state.appTheme);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: Text(S.of(context).exportImportLabel),
                  onTap: () {
                    trackButtonPress('settings_export_import', 'SettingsScreen');
                    _showExportImportDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(S.of(context).settingsDisclaimerLabel),
                  onTap: () {
                    trackButtonPress('settings_disclaimer', 'SettingsScreen');
                    _showDisclaimerDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(S.of(context).settingsReportErrorLabel),
                  onTap: () {
                    trackButtonPress('settings_report_error', 'SettingsScreen');
                    _showReportErrorDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: Text(S.of(context).settingsPrivacySettings),
                  onTap: () {
                    trackButtonPress('settings_privacy', 'SettingsScreen');
                    _showPrivacyDialog(context, state.sendAnonymousData);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline_outlined),
                  title: Text(S.of(context).settingAboutLabel),
                  onTap: () {
                    trackButtonPress('settings_about', 'SettingsScreen');
                    _showAboutDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_outlined),
                  title: Text(S.of(context).settingsChatLabel),
                  onTap: () {
                    trackButtonPress('settings_chat', 'SettingsScreen');
                    _showChatSettingsDialog(context);
                  },
                ),
                const NotificationSettingsWidget(),
                
                // Debug Section
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Debug & Analytics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('View Logistics Logs'),
                  subtitle: const Text('Debug: View tracked user interactions'),
                  onTap: () {
                    trackButtonPress('settings_logistics_debug', 'SettingsScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogisticsDebugScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export Logistics Data'),
                  subtitle: const Text('Export tracking data to JSON file'),
                  onTap: () async {
                    trackButtonPress('settings_logistics_export', 'SettingsScreen');
                    try {
                      final filePath = await LogisticsExportHelper.exportLogsToJson();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logs exported to: $filePath'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Export failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Logistics Statistics'),
                  subtitle: const Text('View tracking statistics and summary'),
                  onTap: () async {
                    trackButtonPress('settings_logistics_stats', 'SettingsScreen');
                    try {
                      final stats = await LogisticsExportHelper.getLogisticsStats();
                      if (mounted) {
                        _showLogisticsStatsDialog(context, stats);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to load stats: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: const Text('Weight Check-in'),
                  subtitle: const Text('Set reminder frequency'),
                  onTap: () {
                    trackButtonPress('settings_weight_checkin', 'SettingsScreen');
                    _showWeightCheckinSettingsDialog(context);
                  },
                ),
                const SizedBox(height: 32.0),
                AppBannerVersion(versionNumber: state.versionNumber)
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, bool usesImperialUnits) async {
    SystemDropDownType selectedUnit = usesImperialUnits
        ? SystemDropDownType.imperial
        : SystemDropDownType.metric;
    final shouldUpdate = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(S.of(context).settingsUnitsLabel),
              content: Wrap(children: [
                Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        enabled: true,
                        filled: false,
                        labelText: S.of(context).settingsSystemLabel,
                      ),
                      onChanged: (value) {
                        selectedUnit = value ?? SystemDropDownType.metric;
                      },
                      items: [
                        DropdownMenuItem(
                            value: SystemDropDownType.metric,
                            child: Text(S.of(context).settingsMetricLabel)),
                        DropdownMenuItem(
                            value: SystemDropDownType.imperial,
                            child: Text(S.of(context).settingsImperialLabel))
                      ],
                    )
                  ],
                ),
              ]),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(S.of(context).dialogOKLabel))
              ]);
        });
    if (shouldUpdate == true) {
      final newValue = selectedUnit == SystemDropDownType.imperial;
      trackSettingsChanged(
        'uses_imperial_units',
        usesImperialUnits,
        newValue,
        additionalData: {
          'screen_name': 'SettingsScreen',
          'setting_category': 'units',
        },
      );
      
      _settingsBloc.setUsesImperialUnits(newValue);
      _settingsBloc.add(LoadSettingsEvent());

      // Update blocs
      _profileBloc.add(LoadProfileEvent());
      _homeBloc.add(LoadItemsEvent());
      _diaryBloc.add(const LoadDiaryYearEvent());
    }
  }

  void _showCalculationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CalculationsDialog(
        settingsBloc: _settingsBloc,
        profileBloc: _profileBloc,
        homeBloc: _homeBloc,
        diaryBloc: _diaryBloc,
        calendarDayBloc: _calendarDayBloc,
      ),
    );
  }

  void _showExportImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportImportDialog(),
    );
  }

  void _showThemeDialog(BuildContext context, AppThemeEntity currentAppTheme) {
    AppThemeEntity selectedTheme = currentAppTheme;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsThemeLabel),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      title:
                          Text(S.of(context).settingsThemeSystemDefaultLabel),
                      value: AppThemeEntity.system,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeLightLabel),
                      value: AppThemeEntity.light,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeDarkLabel),
                      value: AppThemeEntity.dark,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    trackSettingsChanged(
                      'app_theme',
                      currentAppTheme.name,
                      selectedTheme.name,
                      additionalData: {
                        'screen_name': 'SettingsScreen',
                        'setting_category': 'appearance',
                      },
                    );
                    
                    _settingsBloc.setAppTheme(selectedTheme);
                    _settingsBloc.add(LoadSettingsEvent());
                    setState(() {
                      // Update Theme
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateTheme(selectedTheme);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const DisclaimerDialog();
        });
  }

  void _showReportErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsReportErrorLabel),
            content: Text(S.of(context).reportErrorDialogText),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _reportError(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  Future<void> _reportError(BuildContext context) async {
    final reportUri =
        Uri.parse("mailto:${AppConst.reportErrorEmail}?subject=Report_Error");

    if (await canLaunchUrl(reportUri)) {
      launchUrl(reportUri);
    } else {
      // Cannot open email app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningEmail)));
      }
    }
  }

  void _showPrivacyDialog(
      BuildContext context, bool hasAcceptedAnonymousData) async {
    bool switchActive = hasAcceptedAnonymousData;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsPrivacySettings),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return SwitchListTile(
                  title: Text(S.of(context).sendAnonymousUserData),
                  value: switchActive,
                  onChanged: (bool value) {
                    setState(() {
                      switchActive = value;
                    });
                  },
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    trackSettingsChanged(
                      'send_anonymous_data',
                      hasAcceptedAnonymousData,
                      switchActive,
                      additionalData: {
                        'screen_name': 'SettingsScreen',
                        'setting_category': 'privacy',
                      },
                    );
                    
                    _settingsBloc.setHasAcceptedAnonymousData(switchActive);
                    if (!switchActive) Sentry.close();
                    _settingsBloc.add(LoadSettingsEvent());
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  void _showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
          context: context,
          applicationName: S.of(context).appTitle,
          applicationIcon: SizedBox(
              width: 40, child: Image.asset('assets/icon/ont_logo_square.png')),
          applicationVersion: packageInfo.version,
          applicationLegalese: S.of(context).appLicenseLabel,
          children: [
            TextButton(
                onPressed: () {
                  _launchSourceCodeUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.code_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).settingsSourceCodeLabel),
                  ],
                )),
            TextButton(
                onPressed: () {
                  _launchPrivacyPolicyUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.policy_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).privacyPolicyLabel),
                  ],
                ))
          ]);
    }
  }

  void _showChatSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChatSettingsDialog(),
    );
  }

  void _showWeightCheckinSettingsDialog(BuildContext context) async {
    try {
      final currentFrequency = await _weightCheckinUsecase.getCheckinFrequency();
      CheckinFrequency selectedFrequency = currentFrequency;
      
      final shouldUpdate = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Weight Check-in Settings'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'How often would you like to be reminded to check in with your weight?',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ...CheckinFrequency.values.map((frequency) {
                      return RadioListTile<CheckinFrequency>(
                        title: Text(_getFrequencyDisplayName(frequency)),
                        subtitle: Text(_getFrequencyDescription(frequency)),
                        value: frequency,
                        groupValue: selectedFrequency,
                        onChanged: (value) {
                          setState(() {
                            selectedFrequency = value!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(S.of(context).dialogCancelLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(S.of(context).dialogOKLabel),
              ),
            ],
          );
        },
      );

      if (shouldUpdate == true && selectedFrequency != currentFrequency) {
        trackSettingsChanged(
          'weight_checkin_frequency',
          currentFrequency.name,
          selectedFrequency.name,
          additionalData: {
            'screen_name': 'SettingsScreen',
            'setting_category': 'weight_tracking',
          },
        );

        await _weightCheckinUsecase.setCheckinFrequency(selectedFrequency);
        
        // Refresh home bloc to update check-in status
        _homeBloc.add(const LoadItemsEvent());
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weight check-in frequency updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  String _getFrequencyDescription(CheckinFrequency frequency) {
    switch (frequency) {
      case CheckinFrequency.daily:
        return 'Check in every day';
      case CheckinFrequency.weekly:
        return 'Check in once per week';
      case CheckinFrequency.biweekly:
        return 'Check in every two weeks';
      case CheckinFrequency.monthly:
        return 'Check in once per month';
    }
  }

  void _launchSourceCodeUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(AppConst.sourceCodeUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchPrivacyPolicyUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(URLConst.privacyPolicyURLEn);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Cannot open browser app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningBrowser)));
      }
    }
  }

  void _showLogisticsStatsDialog(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logistics Statistics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow('Total Events', '${stats['totalEvents'] ?? 0}'),
                _buildStatRow('Recent Events (24h)', '${stats['recentEvents24h'] ?? 0}'),
                const SizedBox(height: 16),
                const Text(
                  'Event Types:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...((stats['eventTypeCounts'] as Map<String, dynamic>? ?? {}))
                    .entries
                    .map((entry) => _buildStatRow(entry.key, '${entry.value}'))
                    .toList(),
                const SizedBox(height: 16),
                if (stats['oldestEvent'] != null)
                  _buildStatRow('Oldest Event', _formatDate(stats['oldestEvent'])),
                if (stats['newestEvent'] != null)
                  _buildStatRow('Newest Event', _formatDate(stats['newestEvent'])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
