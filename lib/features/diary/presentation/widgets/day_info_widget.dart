import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_or_delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/features/diary/presentation/widgets/food_entry_actions.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DayInfoWidget extends StatelessWidget {
  final DateTime selectedDay;
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivities;
  final List<IntakeEntity> breakfastIntake;
  final List<IntakeEntity> lunchIntake;
  final List<IntakeEntity> dinnerIntake;
  final List<IntakeEntity> snackIntake;

  final bool usesImperialUnits;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
      onDeleteIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onDeleteActivity;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
      AddMealType? type) onCopyIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onCopyActivity;

  const DayInfoWidget({
    super.key,
    required this.selectedDay,
    required this.trackedDayEntity,
    required this.userActivities,
    required this.breakfastIntake,
    required this.lunchIntake,
    required this.dinnerIntake,
    required this.snackIntake,
    required this.usesImperialUnits,
    required this.onDeleteIntake,
    required this.onDeleteActivity,
    required this.onCopyIntake,
    required this.onCopyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final trackedDay = trackedDayEntity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(DateFormat.yMMMMEEEEd().format(selectedDay),
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            trackedDay == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(S.of(context).nothingAddedLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface.withValues(alpha: 0.7))),
                  )
                : const SizedBox(),
            trackedDay != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalorieCard(context, trackedDay),
                        const SizedBox(height: 4.0),
                        Text(_getMacroTrackedDisplayString(trackedDay),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface.withValues(alpha: 0.7))),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 8.0),
            ActivityVerticalList(
                day: selectedDay,
                title: S.of(context).activityLabel,
                userActivityList: userActivities,
                onItemLongPressedCallback: onActivityItemLongPressed),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).breakfastLabel,
              listIcon: Icons.bakery_dining_outlined,
              addMealType: AddMealType.breakfastType,
              intakeList: breakfastIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onItemTappedCallback: (ctx, intake, usesImp) async {
                final changeAmount = await showDialog<double>(
                    context: ctx,
                    builder: (ctx) => EditDialog(
                        intakeEntity: intake,
                        usesImperialUnits: usesImperialUnits));
                if (changeAmount != null) {
                  locator<HomeBloc>()
                      .updateIntakeItem(intake.id, {'amount': changeAmount});
                  locator<HomeBloc>().add(const LoadItemsEvent());
                }
              },
              onCopyIntakeCallback: onCopyIntake,
              usesImperialUnits: usesImperialUnits,
              trackedDayEntity: trackedDay,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).lunchLabel,
              listIcon: Icons.lunch_dining_outlined,
              addMealType: AddMealType.lunchType,
              intakeList: lunchIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onItemTappedCallback: (ctx, intake, usesImp) async {
                final changeAmount = await showDialog<double>(
                    context: ctx,
                    builder: (ctx) => EditDialog(
                        intakeEntity: intake,
                        usesImperialUnits: usesImperialUnits));
                if (changeAmount != null) {
                  locator<HomeBloc>()
                      .updateIntakeItem(intake.id, {'amount': changeAmount});
                  locator<HomeBloc>().add(const LoadItemsEvent());
                }
              },
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback: onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).dinnerLabel,
              listIcon: Icons.dinner_dining_outlined,
              addMealType: AddMealType.dinnerType,
              intakeList: dinnerIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onItemTappedCallback: (ctx, intake, usesImp) async {
                final changeAmount = await showDialog<double>(
                    context: ctx,
                    builder: (ctx) => EditDialog(
                        intakeEntity: intake,
                        usesImperialUnits: usesImperialUnits));
                if (changeAmount != null) {
                  locator<HomeBloc>()
                      .updateIntakeItem(intake.id, {'amount': changeAmount});
                  locator<HomeBloc>().add(const LoadItemsEvent());
                }
              },
              onCopyIntakeCallback: onCopyIntake,
              usesImperialUnits: usesImperialUnits,
            ),
            IntakeVerticalList(
              day: selectedDay,
              title: S.of(context).snackLabel,
              listIcon: CustomIcons.food_apple_outline,
              addMealType: AddMealType.snackType,
              intakeList: snackIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onItemTappedCallback: (ctx, intake, usesImp) async {
                final changeAmount = await showDialog<double>(
                    context: ctx,
                    builder: (ctx) => EditDialog(
                        intakeEntity: intake,
                        usesImperialUnits: usesImperialUnits));
                if (changeAmount != null) {
                  locator<HomeBloc>()
                      .updateIntakeItem(intake.id, {'amount': changeAmount});
                  locator<HomeBloc>().add(const LoadItemsEvent());
                }
              },
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback: onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
            const SizedBox(height: 16.0)
          ],
        )
      ],
    );
  }

  Widget _buildCalorieCard(BuildContext context, TrackedDayEntity trackedDay) {
    // Calculate calories dynamically from actual food entries
    final allIntakes = [...breakfastIntake, ...lunchIntake, ...dinnerIntake, ...snackIntake];
    final calculatedCalories = TrackedDayEntity.calculateCaloriesFromIntakes(allIntakes);
    
    // Hide the card if there are 0 calories
    if (calculatedCalories <= 0) {
      return const SizedBox();
    }
    
    final caloriesTracked = calculatedCalories.toInt();
    final calorieGoal = trackedDay.calorieGoal.toInt();
    
    // Determine colors based on dynamic calorie calculation
    final calculatedCaloriesForColor = TrackedDayEntity.calculateCaloriesFromIntakes(allIntakes);
    final difference = trackedDay.calorieGoal - calculatedCaloriesForColor;
    final isGoodEating = (trackedDay.calorieGoal < calculatedCaloriesForColor) 
        ? difference.abs() < TrackedDayEntity.maxKcalDifferenceOverGoal
        : difference < TrackedDayEntity.maxKcalDifferenceUnderGoal;
    
    final backgroundColor = isGoodEating 
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.errorContainer;
    final textColor = isGoodEating 
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : Theme.of(context).colorScheme.onErrorContainer;
    
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(0.0),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Text(
          '$caloriesTracked/$calorieGoal kcal',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getCaloriesTrackedDisplayString(TrackedDayEntity trackedDay) {
    // Calculate calories dynamically from actual food entries
    final allIntakes = [...breakfastIntake, ...lunchIntake, ...dinnerIntake, ...snackIntake];
    final calculatedCalories = TrackedDayEntity.calculateCaloriesFromIntakes(allIntakes);
    
    final caloriesTracked = calculatedCalories.toInt();
    final calorieGoal = trackedDay.calorieGoal.toInt();

    return '$caloriesTracked/$calorieGoal kcal';
  }

  String _getMacroTrackedDisplayString(TrackedDayEntity trackedDay) {
    // Calculate macros dynamically from actual food entries
    final allIntakes = [...breakfastIntake, ...lunchIntake, ...dinnerIntake, ...snackIntake];
    
    final calculatedCarbs = TrackedDayEntity.calculateCarbsFromIntakes(allIntakes);
    final calculatedFat = TrackedDayEntity.calculateFatFromIntakes(allIntakes);
    final calculatedProtein = TrackedDayEntity.calculateProteinFromIntakes(allIntakes);

    final carbsTracked = calculatedCarbs.floor().toString();
    final fatTracked = calculatedFat.floor().toString();
    final proteinTracked = calculatedProtein.floor().toString();

    final carbsGoal = trackedDay.carbsGoal?.floor().toString() ?? '?';
    final fatGoal = trackedDay.fatGoal?.floor().toString() ?? '?';
    final proteinGoal = trackedDay.proteinGoal?.floor().toString() ?? '?';

    return 'Carbs: $carbsTracked/${carbsGoal}g, Fat: $fatTracked/${fatGoal}g, Protein: $proteinTracked/${proteinGoal}g';
  }

  void showCopyOrDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final copyOrDelete = await showDialog<bool?>(
        context: context, builder: (context) => const CopyOrDeleteDialog());
    if (context.mounted) {
      if (copyOrDelete == null) {
        // Edit details
        // Navigate to full edit meal screen prefilled with this intake's meal
        Navigator.of(context).pushNamed(NavigationOptions.editMealRoute,
            arguments: EditMealScreenArguments(
              selectedDay,
              intakeEntity.meal,
              intakeEntity.type,
              usesImperialUnits,
            ));
      } else if (copyOrDelete == false) {
        showDeleteIntakeDialog(context, intakeEntity);
      } else if (copyOrDelete == true) {
        showCopyDialog(context, intakeEntity);
      }
    }
  }

  void showCopyDialog(BuildContext context, IntakeEntity intakeEntity) async {
    const copyDialog = CopyDialog();
    final selectedMealType = await showDialog<AddMealType>(
        context: context, builder: (context) => copyDialog);
    if (selectedMealType != null) {
      onCopyIntake(intakeEntity, null, selectedMealType);
    }
  }

  void showDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final shouldDeleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());
    if (shouldDeleteIntake != null) {
      onDeleteIntake(intakeEntity, trackedDayEntity);
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    // Use unified action sheet for all food entries regardless of date
    FoodEntryActions.showActionSheet(
      context,
      intakeEntity,
      selectedDay,
      usesImperialUnits: usesImperialUnits,
      onDeleteIntake: onDeleteIntake,
      onCopyIntake: onCopyIntake,
      trackedDayEntity: trackedDayEntity,
    );
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final shouldDeleteActivity = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (shouldDeleteActivity != null) {
      onDeleteActivity(activityEntity, trackedDayEntity);
    }
  }
}
