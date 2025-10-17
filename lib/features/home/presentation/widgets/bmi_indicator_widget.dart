import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/user_bmi_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// Widget that displays BMI category indicator with color-coded status
/// Shows BMI value, category name, and risk status when appropriate
class BMIIndicatorWidget extends StatelessWidget {
  final double bmi;
  final UserNutritionalStatus bmiCategory;
  final bool showDetails;

  const BMIIndicatorWidget({
    Key? key,
    required this.bmi,
    required this.bmiCategory,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBMIColor(colorScheme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBMIColor(colorScheme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getBMIIcon(),
                color: _getBMIColor(colorScheme),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'BMI: ${bmi.toStringAsFixed(1)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getBMIColor(colorScheme),
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 4),
            Text(
              bmiCategory.getName(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getBMIColor(colorScheme),
              ),
            ),
            if (_shouldShowRiskStatus()) ...[
              const SizedBox(height: 2),
              Text(
                bmiCategory.getRiskStatus(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getBMIColor(colorScheme),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Gets the appropriate color for the BMI category
  Color _getBMIColor(ColorScheme colorScheme) {
    switch (bmiCategory) {
      case UserNutritionalStatus.underWeight:
        return Colors.blue;
      case UserNutritionalStatus.normalWeight:
        return Colors.green;
      case UserNutritionalStatus.preObesity:
        return Colors.orange;
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        return Colors.red;
    }
  }

  /// Gets the appropriate icon for the BMI category
  IconData _getBMIIcon() {
    switch (bmiCategory) {
      case UserNutritionalStatus.underWeight:
        return Icons.trending_down;
      case UserNutritionalStatus.normalWeight:
        return Icons.check_circle;
      case UserNutritionalStatus.preObesity:
        return Icons.warning;
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        return Icons.error;
    }
  }

  /// Determines if risk status should be shown (for non-normal categories)
  bool _shouldShowRiskStatus() {
    return bmiCategory != UserNutritionalStatus.normalWeight;
  }
}