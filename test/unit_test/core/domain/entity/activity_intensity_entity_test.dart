import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/activity_intensity_entity.dart';

void main() {
  group('ActivityIntensity', () {
    test('should return correct display names', () {
      expect(ActivityIntensity.light.getDisplayName(), 'Light');
      expect(ActivityIntensity.moderate.getDisplayName(), 'Moderate');
      expect(ActivityIntensity.vigorous.getDisplayName(), 'Vigorous');
      expect(ActivityIntensity.extreme.getDisplayName(), 'Extreme');
    });

    test('should return correct intensity multipliers', () {
      expect(ActivityIntensity.light.getIntensityMultiplier(), 0.8);
      expect(ActivityIntensity.moderate.getIntensityMultiplier(), 1.0);
      expect(ActivityIntensity.vigorous.getIntensityMultiplier(), 1.3);
      expect(ActivityIntensity.extreme.getIntensityMultiplier(), 1.6);
    });

    test('should have multipliers in ascending order', () {
      final multipliers = ActivityIntensity.values
          .map((intensity) => intensity.getIntensityMultiplier())
          .toList();
      
      for (int i = 1; i < multipliers.length; i++) {
        expect(multipliers[i], greaterThan(multipliers[i - 1]));
      }
    });
  });
}