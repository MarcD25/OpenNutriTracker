import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_calendar_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryTableCalendar extends StatefulWidget {
  final Function(DateTime, Map<String, TrackedDayEntity>) onDateSelected;
  final Duration calendarDurationDays;
  final DateTime focusedDate;
  final DateTime currentDate;
  final DateTime selectedDate;

  final Map<String, TrackedDayEntity> trackedDaysMap;
  final Map<String, List<IntakeEntity>> intakeDataMap;

  const DiaryTableCalendar(
      {super.key,
      required this.onDateSelected,
      required this.calendarDurationDays,
      required this.focusedDate,
      required this.currentDate,
      required this.selectedDate,
      required this.trackedDaysMap,
      required this.intakeDataMap});

  @override
  State<DiaryTableCalendar> createState() => _DiaryTableCalendarState();
}

class _DiaryTableCalendarState extends State<DiaryTableCalendar> {
  late DiaryCalendarBloc _diaryCalendarBloc;

  @override
  void initState() {
    super.initState();
    _diaryCalendarBloc = locator<DiaryCalendarBloc>();
    // Load check-in days for the current month
    _diaryCalendarBloc.add(LoadCheckinDaysEvent(widget.focusedDate));
  }

  @override
  Widget build(BuildContext context) {
    print('DiaryTableCalendar: Building calendar widget');
    return BlocBuilder<DiaryCalendarBloc, DiaryCalendarState>(
      bloc: _diaryCalendarBloc,
      builder: (context, calendarState) {
        print('DiaryTableCalendar: BlocBuilder called with state: ${calendarState.runtimeType}');
        Map<DateTime, bool> checkinDays = {};
        Map<DateTime, bool> weightEntryDays = {};
        if (calendarState is DiaryCalendarLoaded) {
          checkinDays = calendarState.checkinDays;
          weightEntryDays = calendarState.weightEntryDays;
          print('DiaryTableCalendar: Calendar state loaded with ${checkinDays.length} check-in days');
          print('DiaryTableCalendar: Frequency: ${calendarState.currentFrequency}');
          print('DiaryTableCalendar: Weight entry days: ${weightEntryDays.length}');
        } else {
          print('DiaryTableCalendar: Calendar state is ${calendarState.runtimeType}');
        }
        
        // Debug: Show actual check-in days
        checkinDays.forEach((date, isCheckin) {
          if (isCheckin && date.month == widget.focusedDate.month) {
            print('DiaryTableCalendar: Real check-in day: ${date.day}/${date.month}');
          }
        });

        return TableCalendar(
      headerStyle:
          const HeaderStyle(titleCentered: true, formatButtonVisible: false),
      focusedDay: widget.focusedDate,
      firstDay: widget.currentDate.subtract(widget.calendarDurationDays),
      lastDay: widget.currentDate.add(widget.calendarDurationDays),
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDateSelected(selectedDay, widget.trackedDaysMap);
      },
      onPageChanged: (focusedDay) {
        // Load check-in days for the new month when user navigates
        _diaryCalendarBloc.add(LoadCheckinDaysEvent(focusedDay));
        // Also trigger the parent callback to update the focused date
        widget.onDateSelected(focusedDay, widget.trackedDaysMap);
      },
      calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          todayTextStyle:
              Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
          todayDecoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2.0),
              shape: BoxShape.circle),
          selectedTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimary) ??
              const TextStyle(),
          selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle)),
      selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, focusedDay) {
          // Normalize the date to midnight for comparison
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final isCheckinDay = checkinDays.entries.any((entry) => 
            entry.key.year == date.year && 
            entry.key.month == date.month && 
            entry.key.day == date.day && 
            entry.value == true
          );
          final hasWeightEntry = weightEntryDays.entries.any((entry) => 
            entry.key.year == date.year && 
            entry.key.month == date.month && 
            entry.key.day == date.day && 
            entry.value == true
          );
          final dayKey = date.toParsedDay();
          final intakeList = widget.intakeDataMap[dayKey] ?? [];
          
          // Debug logging
          if (isCheckinDay || intakeList.isNotEmpty) {
            print('DiaryTableCalendar: Date ${date.day}/${date.month} - CheckinDay: $isCheckinDay, HasWeight: $hasWeightEntry, IntakeCount: ${intakeList.length}');
          }
          
          final dots = <Widget>[];
          
          // First dot: Food intake indicator (green/red based on calorie goal)
          if (intakeList.isNotEmpty) {
            final totalCalories = intakeList.fold<double>(0, (sum, intake) => sum + (intake.totalKcal ?? 0));
            if (totalCalories > 0) {
              final trackedDay = widget.trackedDaysMap[dayKey];
              final color = trackedDay != null 
                  ? TrackedDayEntity.getCalendarDayRatingColorFromIntakes(context, trackedDay.calorieGoal, intakeList)
                  : Theme.of(context).colorScheme.primary;
              
              dots.add(Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                width: 6.0,
                height: 6.0,
              ));
            }
          }
          
          // Second dot: Weight check-in indicator
          if (isCheckinDay) {
            final dotColor = hasWeightEntry ? Colors.blue : Colors.blue.withOpacity(0.4);
            print('DiaryTableCalendar: Adding blue dot for ${date.day}/${date.month} - hasEntry: $hasWeightEntry');
            
            dots.add(Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
              width: 6.0,
              height: 6.0,
            ));
          }
          
          if (dots.isEmpty) {
            return null; // Use default day cell
          }
          
          // Create a custom day cell with dots
          return Container(
            margin: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                // Default day number
                Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                // Dots at the bottom
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dots,
                  ),
                ),
              ],
            ),
          );
        },
      ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
