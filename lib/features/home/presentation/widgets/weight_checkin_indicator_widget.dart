import 'package:flutter/material.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';

/// Widget that shows weight check-in reminders and status
class WeightCheckinIndicatorWidget extends StatelessWidget {
  final bool isTodayCheckinDay;
  final CheckinFrequency checkinFrequency;
  final DateTime? nextCheckinDate;
  final WeightEntryEntity? lastWeightEntry;
  final bool usesImperialUnits;

  const WeightCheckinIndicatorWidget({
    super.key,
    required this.isTodayCheckinDay,
    required this.checkinFrequency,
    this.nextCheckinDate,
    this.lastWeightEntry,
    required this.usesImperialUnits,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTodayCheckinDay && nextCheckinDate == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToWeightCheckin(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isTodayCheckinDay 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.scale,
                    color: isTodayCheckinDay 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTodayCheckinDay 
                            ? 'Weight Check-in Today'
                            : 'Upcoming Weight Check-in',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isTodayCheckinDay 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitleText(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitleText() {
    if (isTodayCheckinDay) {
      if (lastWeightEntry != null) {
        final lastWeight = usesImperialUnits 
            ? '${(lastWeightEntry!.weightKG * 2.20462).toStringAsFixed(1)} lbs'
            : '${lastWeightEntry!.weightKG.toStringAsFixed(1)} kg';
        return 'Last recorded: $lastWeight • Tap to check in';
      } else {
        return 'Tap to record your first weight entry';
      }
    } else if (nextCheckinDate != null) {
      final daysUntil = nextCheckinDate!.difference(DateTime.now()).inDays;
      if (daysUntil == 1) {
        return 'Next check-in tomorrow';
      } else if (daysUntil > 1) {
        return 'Next check-in in $daysUntil days';
      } else {
        return 'Check-in overdue';
      }
    }
    return 'Tap to check in';
  }

  void _navigateToWeightCheckin(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.weightCheckinRoute);
  }
}