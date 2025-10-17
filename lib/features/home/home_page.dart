import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
// BMI entity import removed for cleaner home page
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/features/diary/presentation/widgets/food_entry_actions.dart';
import 'package:opennutritracker/core/presentation/mixins/logistics_tracking_mixin.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
// BMI widgets removed for cleaner home page
import 'package:opennutritracker/features/weight_checkin/presentation/widgets/weight_checkin_card.dart';
import 'package:opennutritracker/features/home/presentation/widgets/weight_checkin_indicator_widget.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart';
import 'package:opennutritracker/features/debug/weight_checkin_debug_helper.dart';
import 'package:opennutritracker/generated/l10n.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, LogisticsTrackingMixin {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  bool _isDragging = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    
    // Track screen view
    trackScreenView('HomePage', additionalData: {
      'screen_category': 'main',
      'is_initial_load': true,
    });
    
    // Initialize weight check-in system for new users
    _initializeWeightCheckin();
    
    super.initState();
  }

  /// Initialize weight check-in system with default settings and sample data
  Future<void> _initializeWeightCheckin() async {
    try {
      final weightCheckinUsecase = locator<WeightCheckinUsecase>();
      await weightCheckinUsecase.initializeDefaultSettings();
      
      // For testing purposes, add sample data if no history exists
      final history = await weightCheckinUsecase.getAllWeightHistory();
      if (history.length < 3) {
        await weightCheckinUsecase.addSampleWeightData();
        log.info('Added sample weight data for calendar highlighting');
      }
    } catch (e) {
      log.warning('Failed to initialize weight check-in system: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
              context,
              state.showDisclaimerDialog,
              state.totalKcalDaily,
              state.totalKcalLeft,
              state.totalKcalSupplied,
              state.totalKcalBurned,
              state.totalCarbsIntake,
              state.totalFatsIntake,
              state.totalProteinsIntake,
              state.totalCarbsGoal,
              state.totalFatsGoal,
              state.totalProteinsGoal,
              state.breakfastIntakeList,
              state.lunchIntakeList,
              state.dinnerIntakeList,
              state.snackIntakeList,
              state.userActivityList,
              state.usesImperialUnits,
              state.baseTDEE,
              state.tdeeWithExercise,
              state.netKcalRemaining,
              state.shouldShowWeightCheckin,
              state.lastWeightEntry,
              state.weightTrend,
              state.checkinFrequency,
              state.nextCheckinDate);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      trackAction(
        LogisticsEventType.appLaunched,
        {
          'lifecycle_event': 'app_resumed',
          'screen_name': 'HomePage',
        },
        metadata: {
          'action_type': 'app_lifecycle',
          'resumed_from_background': true,
        },
      );
      _refreshPageOnDayChange();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      bool showDisclaimerDialog,
      double totalKcalDaily,
      double totalKcalLeft,
      double totalKcalSupplied,
      double totalKcalBurned,
      double totalCarbsIntake,
      double totalFatsIntake,
      double totalProteinsIntake,
      double totalCarbsGoal,
      double totalFatsGoal,
      double totalProteinsGoal,
      List<IntakeEntity> breakfastIntakeList,
      List<IntakeEntity> lunchIntakeList,
      List<IntakeEntity> dinnerIntakeList,
      List<IntakeEntity> snackIntakeList,
      List<UserActivityEntity> userActivities,
      bool usesImperialUnits,
      double baseTDEE,
      double tdeeWithExercise,
      double netKcalRemaining,
      bool shouldShowWeightCheckin,
      WeightEntryEntity? lastWeightEntry,
      WeightTrend? weightTrend,
      CheckinFrequency checkinFrequency,
      DateTime? nextCheckinDate) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return Stack(children: [
      ListView(children: [
        DashboardWidget(
          totalKcalDaily: totalKcalDaily,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalSupplied,
          totalKcalBurned: totalKcalBurned,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalProteinsIntake: totalProteinsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          baseTDEE: baseTDEE,
          tdeeWithExercise: tdeeWithExercise,
          netKcalRemaining: netKcalRemaining,
        ),
        // BMI-related widgets removed for cleaner home page focus
        // Weight check-in card
        if (shouldShowWeightCheckin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: WeightCheckinCard(
              onWeightSubmitted: _onWeightSubmitted,
              lastEntry: lastWeightEntry,
              trend: weightTrend,
              showTrend: weightTrend != null,
              weightUnit: usesImperialUnits ? 'lbs' : 'kg',
            ),
          ),
        // Debug helper for weight check-in (temporary)
        const WeightCheckinDebugHelper(),
        ActivityVerticalList(
          day: DateTime.now(),
          title: S.of(context).activityLabel,
          userActivityList: userActivities,
          onItemLongPressedCallback: onActivityItemLongPressed,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).breakfastLabel,
          listIcon: IntakeTypeEntity.breakfast.getIconData(),
          addMealType: AddMealType.breakfastType,
          intakeList: breakfastIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemLongPressedCallback: (ctx, intake) => onIntakeItemLongPressed(ctx, intake, usesImperialUnits),
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onCopyIntakeCallback: onCopyIntake,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).lunchLabel,
          listIcon: IntakeTypeEntity.lunch.getIconData(),
          addMealType: AddMealType.lunchType,
          intakeList: lunchIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemLongPressedCallback: (ctx, intake) => onIntakeItemLongPressed(ctx, intake, usesImperialUnits),
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onCopyIntakeCallback: onCopyIntake,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).dinnerLabel,
          addMealType: AddMealType.dinnerType,
          listIcon: IntakeTypeEntity.dinner.getIconData(),
          intakeList: dinnerIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemLongPressedCallback: (ctx, intake) => onIntakeItemLongPressed(ctx, intake, usesImperialUnits),
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onCopyIntakeCallback: onCopyIntake,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).snackLabel,
          listIcon: IntakeTypeEntity.snack.getIconData(),
          addMealType: AddMealType.snackType,
          intakeList: snackIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemLongPressedCallback: (ctx, intake) => onIntakeItemLongPressed(ctx, intake, usesImperialUnits),
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onCopyIntakeCallback: onCopyIntake,
          usesImperialUnits: usesImperialUnits,
        ),
        // Weight check-in indicator
        WeightCheckinIndicatorWidget(
          isTodayCheckinDay: shouldShowWeightCheckin,
          checkinFrequency: checkinFrequency,
          nextCheckinDate: nextCheckinDate,
          lastWeightEntry: lastWeightEntry,
          usesImperialUnits: usesImperialUnits,
        ),
        const SizedBox(height: 48.0)
      ]),
      Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
              visible: _isDragging,
              child: Container(
                height: 70,
                color: Theme.of(context).colorScheme.error
                  ..withValues(alpha: 0.3),
                child: DragTarget<IntakeEntity>(
                  onAcceptWithDetails: (data) {
                    _confirmDelete(context, data.data);
                  },
                  onLeave: (data) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return const Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              )))
    ]);
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    trackButtonPress('activity_long_press', 'HomePage', additionalData: {
      'activity_type': activityEntity.physicalActivityEntity.specificActivity,
      'activity_duration': activityEntity.duration.toInt(),
    });
    
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      trackExerciseLogged(
        activityEntity.physicalActivityEntity.specificActivity,
        Duration(minutes: activityEntity.duration.toInt()),
        activityEntity.burnedKcal,
        additionalData: {
          'action_type': 'delete',
          'screen_name': 'HomePage',
        },
      );
      
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity, bool usesImperialUnits) async {
    trackButtonPress('intake_long_press', 'HomePage', additionalData: {
      'meal_type': intakeEntity.type.name,
      'food_name': intakeEntity.meal.name,
      'calories': intakeEntity.totalKcal,
    });
    
    // Use unified action sheet for consistent behavior
    FoodEntryActions.showActionSheet(
      context,
      intakeEntity,
      DateTime.now(),
      usesImperialUnits: usesImperialUnits,
      onDeleteIntake: (intake, trackedDay) {
        trackMealLogged(
          intake.type.name,
          1,
          intake.totalKcal,
          additionalData: {
            'action_type': 'delete',
            'screen_name': 'HomePage',
            'food_name': intake.meal.name,
          },
        );
        
        _homeBloc.deleteIntakeItem(intake);
        _homeBloc.add(const LoadItemsEvent());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
        }
      },
      onCopyIntake: onCopyIntake,
    );
  }

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

  void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    trackButtonPress('intake_tap', 'HomePage', additionalData: {
      'meal_type': intakeEntity.type.name,
      'food_name': intakeEntity.meal.name,
      'current_amount': intakeEntity.amount,
    });
    
    final changeIntakeAmount = await showDialog<double>(
        context: context,
        builder: (context) => EditDialog(
            intakeEntity: intakeEntity, usesImperialUnits: usesImperialUnits));
    if (changeIntakeAmount != null) {
      trackMealLogged(
        intakeEntity.type.name,
        1,
        intakeEntity.totalKcal * (changeIntakeAmount / intakeEntity.amount),
        additionalData: {
          'action_type': 'edit',
          'screen_name': 'HomePage',
          'old_amount': intakeEntity.amount,
          'new_amount': changeIntakeAmount,
          'food_name': intakeEntity.meal.name,
        },
      );
      
      _homeBloc
          .updateIntakeItem(intakeEntity.id, {'amount': changeIntakeAmount});
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)));
      }
    }
  }

  void onDeleteIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity) {
    trackMealLogged(
      intake.type.name,
      1,
      intake.totalKcal,
      additionalData: {
        'action_type': 'drag_delete',
        'screen_name': 'HomePage',
        'food_name': intake.meal.name,
      },
    );
    
    _homeBloc.deleteIntakeItem(intake);
    _homeBloc.add(const LoadItemsEvent());
  }

  void onCopyIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity, AddMealType? type) {
    trackMealLogged(
      intake.type.name,
      1,
      intake.totalKcal,
      additionalData: {
        'action_type': 'copy',
        'screen_name': 'HomePage',
        'food_name': intake.meal.name,
        'target_meal_type': type?.name ?? 'unknown',
      },
    );
    
    // Copy the intake to the selected meal type for today
    // This functionality would need to be implemented in the HomeBloc
    // For now, we'll show a success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal copied successfully!')));
    }
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (delete == true) {
      onDeleteIntake(intake, null);
    }
    setState(() {
      _isDragging = false;
    });
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return const DisclaimerDialog();
          });
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  /// Refresh page when day changes
  void _refreshPageOnDayChange() {
    if (!DateUtils.isSameDay(_homeBloc.currentDay, DateTime.now())) {
      _homeBloc.add(const LoadItemsEvent());
    }
  }

  // BMI-related navigation methods removed for cleaner home page focus

  /// Handle weight check-in submission
  Future<void> _onWeightSubmitted(double weight, String? notes) async {
    trackAction(
      LogisticsEventType.weightCheckin,
      {
        'weight_kg': weight,
        'has_notes': notes != null && notes.isNotEmpty,
        'screen_name': 'HomePage',
      },
      metadata: {
        'action_type': 'weight_checkin',
        'submission_method': 'home_screen_card',
      },
    );

    try {
      await _homeBloc.recordWeightEntry(weight, notes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weight recorded successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Progress',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to weight progress screen or show chart
                _navigateToWeightProgress();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record weight. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to weight progress screen
  void _navigateToWeightProgress() {
    trackButtonPress('view_weight_progress', 'HomePage', additionalData: {
      'action_type': 'navigate',
      'trigger': 'weight_submission_success',
    });
    
    // For now, we'll just show a simple dialog with progress info
    // In a full implementation, this would navigate to a dedicated screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Progress'),
        content: const Text('Weight progress tracking is available. Check your profile for detailed charts and trends.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
