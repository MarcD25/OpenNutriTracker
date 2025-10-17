import 'package:flutter/material.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/core/utils/calc/enhanced_calorie_goal_calc.dart';
import 'package:opennutritracker/core/presentation/mixins/logistics_tracking_mixin.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// Widget for easy calorie adjustment in settings
/// Provides a user-friendly interface to adjust daily calorie targets
class CalorieAdjustmentWidget extends StatefulWidget {
  final SettingsBloc settingsBloc;
  final ProfileBloc profileBloc;
  final HomeBloc homeBloc;
  final DiaryBloc diaryBloc;
  final CalendarDayBloc calendarDayBloc;

  const CalorieAdjustmentWidget({
    super.key,
    required this.settingsBloc,
    required this.profileBloc,
    required this.homeBloc,
    required this.diaryBloc,
    required this.calendarDayBloc,
  });

  @override
  State<CalorieAdjustmentWidget> createState() => _CalorieAdjustmentWidgetState();
}

class _CalorieAdjustmentWidgetState extends State<CalorieAdjustmentWidget> with LogisticsTrackingMixin {
  double _currentAdjustment = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentAdjustment();
  }

  Future<void> _loadCurrentAdjustment() async {
    try {
      final adjustment = await widget.settingsBloc.getKcalAdjustment();
      setState(() {
        _currentAdjustment = adjustment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentAdjustment = 0.0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        leading: Icon(Icons.tune_outlined),
        title: Text('Calorie Adjustment'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.tune_outlined),
      title: Text(S.of(context).dailyKcalAdjustmentLabel),
      subtitle: Text(_getAdjustmentDescription()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_currentAdjustment >= 0 ? '+' : ''}${_currentAdjustment.round()} ${S.of(context).kcalLabel}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getAdjustmentColor(),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        trackButtonPress('settings_calorie_adjustment', 'SettingsScreen');
        _showCalorieAdjustmentDialog();
      },
    );
  }

  String _getAdjustmentDescription() {
    if (_currentAdjustment == 0) {
      return 'No adjustment applied';
    } else if (_currentAdjustment > 0) {
      return 'Increasing daily calorie target';
    } else {
      return 'Decreasing daily calorie target';
    }
  }

  Color _getAdjustmentColor() {
    if (_currentAdjustment == 0) {
      return Colors.grey;
    } else if (_currentAdjustment > 0) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  void _showCalorieAdjustmentDialog() {
    double tempAdjustment = _currentAdjustment;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.of(context).dailyKcalAdjustmentLabel),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjust your daily calorie target by a fixed amount. This will be applied consistently across all app functions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Current adjustment: ${tempAdjustment >= 0 ? '+' : ''}${tempAdjustment.round()} ${S.of(context).kcalLabel}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getAdjustmentColorForValue(tempAdjustment),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: Slider(
                      min: -1000,
                      max: 1000,
                      divisions: 200,
                      value: tempAdjustment,
                      label: '${tempAdjustment >= 0 ? '+' : ''}${tempAdjustment.round()} ${S.of(context).kcalLabel}',
                      onChanged: (value) {
                        setDialogState(() {
                          tempAdjustment = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPresetButtons(tempAdjustment, (preset) {
                    setDialogState(() {
                      tempAdjustment = preset;
                    });
                  }),
                  const SizedBox(height: 16),
                  Text(
                    _getAdjustmentExplanation(tempAdjustment),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).dialogCancelLabel),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempAdjustment = 0;
                    });
                  },
                  child: Text(S.of(context).buttonResetLabel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _saveAdjustment(tempAdjustment);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(S.of(context).dialogOKLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPresetButtons(double currentValue, Function(double) onPresetSelected) {
    final presets = [-500, -250, -100, 0, 100, 250, 500];
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: presets.map((preset) {
        final isSelected = currentValue.round() == preset;
        return FilterChip(
          label: Text('${preset >= 0 ? '+' : ''}$preset'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onPresetSelected(preset.toDouble());
            }
          },
          selectedColor: _getAdjustmentColorForValue(preset.toDouble()).withValues(alpha: 0.2),
          checkmarkColor: _getAdjustmentColorForValue(preset.toDouble()),
        );
      }).toList(),
    );
  }

  Color _getAdjustmentColorForValue(double value) {
    if (value == 0) {
      return Colors.grey;
    } else if (value > 0) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getAdjustmentExplanation(double adjustment) {
    if (adjustment == 0) {
      return 'No adjustment will be applied to your calculated calorie targets.';
    } else if (adjustment > 0) {
      return 'Your daily calorie target will be increased by ${adjustment.round()} calories. This can help with weight gain or increased energy needs.';
    } else {
      return 'Your daily calorie target will be decreased by ${adjustment.abs().round()} calories. This can help with weight loss goals.';
    }
  }

  Future<void> _saveAdjustment(double adjustment) async {
    try {
      trackSettingsChanged(
        'calorie_adjustment',
        _currentAdjustment,
        adjustment,
        additionalData: {
          'screen_name': 'SettingsScreen',
          'setting_category': 'calorie_goals',
          'adjustment_difference': adjustment - _currentAdjustment,
        },
      );

      // Update the enhanced calorie calculation system
      await EnhancedCalorieGoalCalc.updateUserCalorieAdjustment(adjustment);
      
      // Update settings bloc
      widget.settingsBloc.setKcalAdjustment(adjustment.toInt().toDouble());
      widget.settingsBloc.add(LoadSettingsEvent());
      
      // Update all dependent blocs to ensure consistency
      widget.profileBloc.add(LoadProfileEvent());
      widget.homeBloc.add(const LoadItemsEvent());
      widget.diaryBloc.add(const LoadDiaryYearEvent());
      widget.calendarDayBloc.add(RefreshCalendarDayEvent());
      
      // Update local state
      setState(() {
        _currentAdjustment = adjustment;
      });
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Calorie adjustment updated successfully! Changes will be applied across all app functions.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update calorie adjustment: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}