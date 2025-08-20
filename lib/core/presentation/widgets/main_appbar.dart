import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;

  const MainAppbar({super.key, required this.title, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Icon(iconData),
      title: Text(title),
      actions: [
        if (title.toLowerCase().contains('diary'))
          IconButton(
              onPressed: () {
                locator<DiaryBloc>().add(const LoadDiaryYearEvent());
                locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
              },
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh)),
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
            },
            icon: const Icon(Icons.settings_outlined))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
