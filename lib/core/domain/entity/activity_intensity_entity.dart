enum ActivityIntensity {
  light,
  moderate,
  vigorous,
  extreme;

  String getDisplayName() {
    switch (this) {
      case ActivityIntensity.light:
        return 'Light';
      case ActivityIntensity.moderate:
        return 'Moderate';
      case ActivityIntensity.vigorous:
        return 'Vigorous';
      case ActivityIntensity.extreme:
        return 'Extreme';
    }
  }

  double getIntensityMultiplier() {
    switch (this) {
      case ActivityIntensity.light:
        return 0.8;
      case ActivityIntensity.moderate:
        return 1.0;
      case ActivityIntensity.vigorous:
        return 1.3;
      case ActivityIntensity.extreme:
        return 1.6;
    }
  }
}