import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/user_bmi_entity.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_trend_entity.dart';

class GoalAdjustmentSuggestionWidget extends StatelessWidget {
  final WeightTrend weightTrend;
  final double currentBMI;
  final UserNutritionalStatus bmiCategory;
  final VoidCallback onAdjustGoals;
  final VoidCallback onDismiss;

  const GoalAdjustmentSuggestionWidget({
    Key? key,
    required this.weightTrend,
    required this.currentBMI,
    required this.bmiCategory,
    required this.onAdjustGoals,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestion = _generateSuggestion();
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Goal Adjustment Suggestion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTrendSummary(),
            const SizedBox(height: 12),
            Text(
              suggestion.message,
              style: const TextStyle(fontSize: 14),
            ),
            if (suggestion.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...suggestion.details.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        detail,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Not Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAdjustGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Adjust Goals'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSummary() {
    Color trendColor;
    IconData trendIcon;
    
    switch (weightTrend.trendDirection) {
      case WeightTrendDirection.increasing:
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
        break;
      case WeightTrendDirection.decreasing:
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
        break;
      case WeightTrendDirection.stable:
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${weightTrend.description} • ${weightTrend.weeklyChangeText}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: trendColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  GoalSuggestion _generateSuggestion() {
    final isUnderweight = bmiCategory == UserNutritionalStatus.underWeight;
    final isOverweight = bmiCategory == UserNutritionalStatus.preObesity ||
                        bmiCategory == UserNutritionalStatus.obesityClassI ||
                        bmiCategory == UserNutritionalStatus.obesityClassII ||
                        bmiCategory == UserNutritionalStatus.obesityClassIII;
    
    switch (weightTrend.trendDirection) {
      case WeightTrendDirection.increasing:
        if (isUnderweight) {
          return GoalSuggestion(
            message: 'Great! You\'re gaining weight. Consider adjusting your calorie goals to maintain this healthy progress.',
            details: [
              'Your current BMI indicates you may benefit from continued weight gain',
              'Consider increasing protein intake to support healthy muscle growth',
              'Monitor your progress and adjust goals as you approach a healthy weight range',
            ],
          );
        } else if (isOverweight) {
          return GoalSuggestion(
            message: 'You\'ve been gaining weight. Consider adjusting your goals to support weight loss.',
            details: [
              'Create a moderate calorie deficit (300-500 calories per day)',
              'Focus on nutrient-dense, lower-calorie foods',
              'Consider increasing physical activity',
              'Aim for 1-2 pounds of weight loss per week',
            ],
          );
        } else {
          return GoalSuggestion(
            message: 'You\'re gaining weight. Consider whether this aligns with your health goals.',
            details: [
              'If weight gain is intentional, ensure it\'s from healthy sources',
              'If unintentional, consider reducing calorie intake slightly',
              'Monitor your BMI to stay within the healthy range',
            ],
          );
        }
        
      case WeightTrendDirection.decreasing:
        if (isUnderweight) {
          return GoalSuggestion(
            message: 'You\'re losing weight, but your BMI suggests you may need to gain weight instead.',
            details: [
              'Consider increasing your daily calorie intake',
              'Focus on nutrient-dense, calorie-rich foods',
              'Add healthy fats and proteins to your meals',
              'Consult with a healthcare provider if weight loss continues',
            ],
          );
        } else if (isOverweight) {
          return GoalSuggestion(
            message: 'Excellent progress with weight loss! Consider fine-tuning your goals to maintain this trend.',
            details: [
              'You\'re on track - maintain your current calorie deficit',
              'Ensure you\'re getting adequate nutrition while losing weight',
              'Consider strength training to preserve muscle mass',
              'Reassess goals as you approach your target weight',
            ],
          );
        } else {
          return GoalSuggestion(
            message: 'You\'re losing weight. Make sure this aligns with your health goals.',
            details: [
              'If weight loss is intentional, ensure it\'s at a healthy rate (1-2 lbs/week)',
              'If unintentional, consider increasing calorie intake',
              'Monitor to ensure you stay within a healthy BMI range',
            ],
          );
        }
        
      case WeightTrendDirection.stable:
        if (isUnderweight || isOverweight) {
          return GoalSuggestion(
            message: 'Your weight has been stable. Consider adjusting your goals to move toward a healthier BMI range.',
            details: [
              isUnderweight 
                ? 'Gradually increase calorie intake to support healthy weight gain'
                : 'Create a moderate calorie deficit to support weight loss',
              'Small, consistent changes are more sustainable than drastic adjustments',
              'Focus on building healthy habits that support your goals',
            ],
          );
        } else {
          return GoalSuggestion(
            message: 'Great job maintaining a stable, healthy weight! Your current goals seem to be working well.',
            details: [
              'Continue with your current nutrition and activity patterns',
              'Consider focusing on body composition goals if desired',
              'Regular check-ins help maintain long-term success',
            ],
          );
        }
    }
  }
}

class GoalSuggestion {
  final String message;
  final List<String> details;

  GoalSuggestion({
    required this.message,
    required this.details,
  });
}