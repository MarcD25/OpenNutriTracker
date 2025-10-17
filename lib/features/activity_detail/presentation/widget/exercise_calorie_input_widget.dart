import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/domain/entity/activity_intensity_entity.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/features/activity_detail/domain/service/calorie_validation_service.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ExerciseCalorieInputWidget extends StatefulWidget {
  final TextEditingController durationController;
  final TextEditingController calorieController;
  final PhysicalActivityEntity activity;
  final UserEntity user;
  final Function(double calories, bool isManual) onCaloriesChanged;

  const ExerciseCalorieInputWidget({
    super.key,
    required this.durationController,
    required this.calorieController,
    required this.activity,
    required this.user,
    required this.onCaloriesChanged,
  });

  @override
  State<ExerciseCalorieInputWidget> createState() =>
      _ExerciseCalorieInputWidgetState();
}

class _ExerciseCalorieInputWidgetState
    extends State<ExerciseCalorieInputWidget> {
  ActivityIntensity _selectedIntensity = ActivityIntensity.moderate;
  bool _isManualCalorieEntry = false;
  CalorieValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    widget.durationController.addListener(_onDurationChanged);
    widget.calorieController.addListener(_onCalorieChanged);
    _calculateAutoCalories();
  }

  @override
  void dispose() {
    widget.durationController.removeListener(_onDurationChanged);
    widget.calorieController.removeListener(_onCalorieChanged);
    super.dispose();
  }

  void _onDurationChanged() {
    if (!_isManualCalorieEntry) {
      _calculateAutoCalories();
    }
    _validateCalories();
  }

  void _onCalorieChanged() {
    if (_isManualCalorieEntry) {
      _validateCalories();
      final calories = double.tryParse(widget.calorieController.text) ?? 0.0;
      widget.onCaloriesChanged(calories, true);
    }
  }

  void _calculateAutoCalories() {
    final duration = double.tryParse(widget.durationController.text) ?? 0.0;
    if (duration > 0) {
      final calories = CalorieValidationService.calculateRecommendedCalories(
        user: widget.user,
        activity: widget.activity,
        durationMinutes: duration,
        intensityMultiplier: _selectedIntensity.getIntensityMultiplier(),
      );
      
      widget.calorieController.text = calories.toStringAsFixed(0);
      widget.onCaloriesChanged(calories, false);
    }
  }

  void _validateCalories() {
    final duration = double.tryParse(widget.durationController.text) ?? 0.0;
    final calories = double.tryParse(widget.calorieController.text) ?? 0.0;
    
    if (duration > 0 && calories > 0) {
      setState(() {
        _validationResult = CalorieValidationService.validateCalories(
          calories: calories,
          durationMinutes: duration,
          user: widget.user,
          activity: widget.activity,
        );
      });
    } else {
      setState(() {
        _validationResult = null;
      });
    }
  }

  void _onIntensityChanged(ActivityIntensity? intensity) {
    if (intensity != null) {
      setState(() {
        _selectedIntensity = intensity;
      });
      if (!_isManualCalorieEntry) {
        _calculateAutoCalories();
      }
    }
  }

  void _toggleManualEntry() {
    setState(() {
      _isManualCalorieEntry = !_isManualCalorieEntry;
    });
    
    if (!_isManualCalorieEntry) {
      _calculateAutoCalories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration Input
        TextFormField(
          controller: widget.durationController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
            TextInputFormatter.withFunction(
              (oldValue, newValue) => newValue.copyWith(
                text: newValue.text.replaceAll(',', '.'),
              ),
            ),
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: S.of(context).quantityLabel,
            suffixText: 'min',
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Intensity Selector
        DropdownButtonFormField<ActivityIntensity>(
          value: _selectedIntensity,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Intensity Level',
          ),
          items: ActivityIntensity.values.map((intensity) {
            return DropdownMenuItem(
              value: intensity,
              child: Text(intensity.getDisplayName()),
            );
          }).toList(),
          onChanged: _onIntensityChanged,
        ),
        
        const SizedBox(height: 16),
        
        // Auto-calculation display with manual override
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.calorieController,
                keyboardType: TextInputType.number,
                enabled: _isManualCalorieEntry,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) => newValue.copyWith(
                      text: newValue.text.replaceAll(',', '.'),
                    ),
                  ),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Calories Burned',
                  suffixText: 'kcal',
                  prefixIcon: _isManualCalorieEntry 
                      ? const Icon(Icons.edit) 
                      : const Icon(Icons.auto_awesome),
                  helperText: _isManualCalorieEntry 
                      ? 'Manual entry' 
                      : 'Auto-calculated',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _toggleManualEntry,
              icon: Icon(_isManualCalorieEntry ? Icons.auto_awesome : Icons.edit),
              tooltip: _isManualCalorieEntry 
                  ? 'Switch to auto-calculation' 
                  : 'Enter manually',
            ),
          ],
        ),
        
        // Validation Warning
        if (_validationResult != null && _validationResult!.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CalorieValidationWarning(
              validationResult: _validationResult!,
            ),
          ),
      ],
    );
  }
}

class CalorieValidationWarning extends StatelessWidget {
  final CalorieValidationResult validationResult;

  const CalorieValidationWarning({
    super.key,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (validationResult.severity) {
      case ValidationSeverity.warning:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.warning_amber;
        break;
      case ValidationSeverity.error:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case ValidationSeverity.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              validationResult.message!,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}