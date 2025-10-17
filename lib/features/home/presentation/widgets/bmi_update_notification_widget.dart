import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/user_bmi_entity.dart';

class BMIUpdateNotificationWidget extends StatelessWidget {
  final double oldBMI;
  final double newBMI;
  final UserNutritionalStatus oldCategory;
  final UserNutritionalStatus newCategory;
  final VoidCallback onDismiss;
  final VoidCallback? onReviewGoals;

  const BMIUpdateNotificationWidget({
    Key? key,
    required this.oldBMI,
    required this.newBMI,
    required this.oldCategory,
    required this.newCategory,
    required this.onDismiss,
    this.onReviewGoals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bmiChange = newBMI - oldBMI;
    final isImprovement = _isImprovement();
    final changeText = bmiChange > 0 ? '+${bmiChange.toStringAsFixed(1)}' : bmiChange.toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: isImprovement ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isImprovement ? Icons.trending_up : Icons.info_outline,
                  color: isImprovement ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BMI Updated',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isImprovement ? Colors.green.shade700 : Colors.orange.shade700,
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
            Text(
              'Your BMI has changed from ${oldBMI.toStringAsFixed(1)} to ${newBMI.toStringAsFixed(1)} ($changeText)',
              style: const TextStyle(fontSize: 14),
            ),
            if (oldCategory != newCategory) ...[
              const SizedBox(height: 8),
              Text(
                'Category: ${_getCategoryDisplayName(oldCategory)} → ${_getCategoryDisplayName(newCategory)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isImprovement ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _getMotivationalMessage(),
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (onReviewGoals != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReviewGoals,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Review Goals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isImprovement ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isImprovement() {
    // Consider it an improvement if moving towards normal weight
    if (oldCategory == UserNutritionalStatus.normalWeight) {
      return newCategory == UserNutritionalStatus.normalWeight;
    }
    
    if (oldCategory == UserNutritionalStatus.underWeight) {
      return newBMI > oldBMI; // Gaining weight is good for underweight
    }
    
    if (oldCategory == UserNutritionalStatus.preObesity ||
        oldCategory == UserNutritionalStatus.obesityClassI ||
        oldCategory == UserNutritionalStatus.obesityClassII ||
        oldCategory == UserNutritionalStatus.obesityClassIII) {
      return newBMI < oldBMI; // Losing weight is good for overweight/obese
    }
    
    return false;
  }

  String _getCategoryDisplayName(UserNutritionalStatus category) {
    switch (category) {
      case UserNutritionalStatus.underWeight:
        return 'Underweight';
      case UserNutritionalStatus.normalWeight:
        return 'Normal Weight';
      case UserNutritionalStatus.preObesity:
        return 'Overweight';
      case UserNutritionalStatus.obesityClassI:
        return 'Obesity Class I';
      case UserNutritionalStatus.obesityClassII:
        return 'Obesity Class II';
      case UserNutritionalStatus.obesityClassIII:
        return 'Obesity Class III';
    }
  }

  String _getMotivationalMessage() {
    if (_isImprovement()) {
      return 'Great progress! Keep up the good work with your health journey.';
    } else if (oldCategory != newCategory) {
      return 'Your BMI category has changed. Consider reviewing your nutrition goals.';
    } else {
      return 'Your BMI has been updated. Stay consistent with your health goals.';
    }
  }
}