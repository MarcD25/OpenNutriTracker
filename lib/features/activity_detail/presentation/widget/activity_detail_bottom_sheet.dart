import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:opennutritracker/features/activity_detail/presentation/widget/exercise_calorie_input_widget.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ActivityDetailBottomSheet extends StatefulWidget {
  final Function(BuildContext, double, bool) onAddButtonPressed;
  final PhysicalActivityEntity activityEntity;
  final TextEditingController quantityTextController;
  final ActivityDetailBloc activityDetailBloc;
  final UserEntity userEntity;

  const ActivityDetailBottomSheet(
      {super.key,
      required this.onAddButtonPressed,
      required this.quantityTextController,
      required this.activityEntity,
      required this.activityDetailBloc,
      required this.userEntity});

  @override
  State<ActivityDetailBottomSheet> createState() =>
      _ActivityDetailBottomSheetState();
}

class _ActivityDetailBottomSheetState extends State<ActivityDetailBottomSheet> {
  late TextEditingController _calorieController;
  double _currentCalories = 0.0;
  bool _isManualCalorieEntry = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  void _onCaloriesChanged(double calories, bool isManual) {
    setState(() {
      _currentCalories = calories;
      _isManualCalorieEntry = isManual;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      elevation: 10,
      onClosing: () {},
      enableDrag: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 8.0),
                child: Column(
                  children: [
                    ExerciseCalorieInputWidget(
                      durationController: widget.quantityTextController,
                      calorieController: _calorieController,
                      activity: widget.activityEntity,
                      user: widget.userEntity,
                      onCaloriesChanged: _onCaloriesChanged,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, // Make button full width
                      child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onAddButtonPressed(context, _currentCalories, _isManualCalorieEntry);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ).copyWith(
                              elevation: ButtonStyleButton.allOrNull(0.0)),
                          icon: const Icon(Icons.add_outlined),
                          label: Text(S.of(context).addLabel)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
