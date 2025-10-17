import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_dialog.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';

enum FoodEntryAction { editDetails, copy, delete }

class FoodEntryActions {
  /// Get available actions for any food entry regardless of date
  static List<FoodEntryAction> getAvailableActions(
      IntakeEntity entry, DateTime entryDate) {
    // Return consistent actions regardless of entry date
    return [
      FoodEntryAction.editDetails,
      FoodEntryAction.copy,
      FoodEntryAction.delete,
    ];
  }

  /// Handle the selected action for a food entry
  static void handleAction(
    FoodEntryAction action,
    IntakeEntity entry,
    DateTime entryDate,
    BuildContext context, {
    required bool usesImperialUnits,
    required Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
        onDeleteIntake,
    required Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
            AddMealType? type)
        onCopyIntake,
    TrackedDayEntity? trackedDayEntity,
  }) {
    switch (action) {
      case FoodEntryAction.editDetails:
        _showEditDialog(entry, entryDate, context, usesImperialUnits);
        break;
      case FoodEntryAction.copy:
        _showCopyDialog(entry, entryDate, context, onCopyIntake, trackedDayEntity);
        break;
      case FoodEntryAction.delete:
        _confirmDelete(entry, context, onDeleteIntake, trackedDayEntity);
        break;
    }
  }

  /// Show action sheet with consistent options for all food entries
  static void showActionSheet(
    BuildContext context,
    IntakeEntity entry,
    DateTime entryDate, {
    required bool usesImperialUnits,
    required Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
        onDeleteIntake,
    required Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
            AddMealType? type)
        onCopyIntake,
    TrackedDayEntity? trackedDayEntity,
  }) {
    final actions = getAvailableActions(entry, entryDate);

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              S.of(context).copyOrDeleteTimeDialogTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...actions.map((action) => ListTile(
                leading: Icon(getActionIcon(action)),
                title: Text(_getActionTitle(action, context)),
                onTap: () {
                  Navigator.pop(context);
                  handleAction(
                    action,
                    entry,
                    entryDate,
                    context,
                    usesImperialUnits: usesImperialUnits,
                    onDeleteIntake: onDeleteIntake,
                    onCopyIntake: onCopyIntake,
                    trackedDayEntity: trackedDayEntity,
                  );
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static IconData getActionIcon(FoodEntryAction action) {
    switch (action) {
      case FoodEntryAction.editDetails:
        return Icons.edit;
      case FoodEntryAction.copy:
        return Icons.copy;
      case FoodEntryAction.delete:
        return Icons.delete;
    }
  }

  static String _getActionTitle(FoodEntryAction action, BuildContext context) {
    switch (action) {
      case FoodEntryAction.editDetails:
        return 'Edit Details';
      case FoodEntryAction.copy:
        return S.of(context).dialogCopyLabel;
      case FoodEntryAction.delete:
        return S.of(context).dialogDeleteLabel;
    }
  }

  static void _showEditDialog(IntakeEntity entry, DateTime entryDate,
      BuildContext context, bool usesImperialUnits) {
    // Navigate to full edit meal screen prefilled with this intake's meal
    Navigator.of(context).pushNamed(
      NavigationOptions.editMealRoute,
      arguments: EditMealScreenArguments(
        entryDate,
        entry.meal,
        entry.type,
        usesImperialUnits,
      ),
    );
  }

  static void _showCopyDialog(
    IntakeEntity entry,
    DateTime entryDate,
    BuildContext context,
    Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
            AddMealType? type)
        onCopyIntake,
    TrackedDayEntity? trackedDayEntity,
  ) {
    const copyDialog = CopyDialog();
    showDialog<AddMealType>(
      context: context,
      builder: (context) => copyDialog,
    ).then((selectedMealType) {
      if (selectedMealType != null) {
        onCopyIntake(entry, trackedDayEntity, selectedMealType);
      }
    });
  }

  static void _confirmDelete(
    IntakeEntity entry,
    BuildContext context,
    Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
        onDeleteIntake,
    TrackedDayEntity? trackedDayEntity,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    ).then((shouldDelete) {
      if (shouldDelete == true) {
        onDeleteIntake(entry, trackedDayEntity);
      }
    });
  }
}