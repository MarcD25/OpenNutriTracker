import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// Widget that displays a prompt for goal reassessment when BMI has changed significantly
/// Provides options to review goals or dismiss the prompt
class GoalReassessmentWidget extends StatelessWidget {
  final VoidCallback onReviewGoals;
  final VoidCallback onDismiss;
  final double? previousBMI;
  final double currentBMI;

  const GoalReassessmentWidget({
    Key? key,
    required this.onReviewGoals,
    required this.onDismiss,
    this.previousBMI,
    required this.currentBMI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary,
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
                Icons.lightbulb_outline,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Goal Review Suggested',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: colorScheme.primary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getReassessmentMessage(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          if (previousBMI != null) ...[
            const SizedBox(height: 8),
            Text(
              'BMI change: ${previousBMI!.toStringAsFixed(1)} → ${currentBMI.toStringAsFixed(1)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Later',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onReviewGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Review Goals'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate reassessment message based on BMI change
  String _getReassessmentMessage(BuildContext context) {
    if (previousBMI == null) {
      return 'Your BMI has been calculated. Consider reviewing your nutrition goals to ensure they align with your current health status.';
    }
    
    final bmiChange = currentBMI - previousBMI!;
    
    if (bmiChange > 0) {
      return 'Your BMI has increased since your last calculation. You might want to review your nutrition goals to ensure they still align with your health objectives.';
    } else {
      return 'Your BMI has decreased since your last calculation. Great progress! Consider reviewing your goals to maintain your healthy trajectory.';
    }
  }
}