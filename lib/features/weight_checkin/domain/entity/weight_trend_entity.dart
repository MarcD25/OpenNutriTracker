import 'package:equatable/equatable.dart';

class WeightTrend extends Equatable {
  final WeightTrendDirection trendDirection;
  final double averageWeeklyChange;
  final double totalChange;
  final WeightTrendConfidence confidence;
  final int dataPoints;

  const WeightTrend({
    required this.trendDirection,
    required this.averageWeeklyChange,
    required this.totalChange,
    required this.confidence,
    required this.dataPoints,
  });

  /// Gets a human-readable description of the trend
  String get description {
    switch (trendDirection) {
      case WeightTrendDirection.increasing:
        return 'Weight is trending upward';
      case WeightTrendDirection.decreasing:
        return 'Weight is trending downward';
      case WeightTrendDirection.stable:
        return 'Weight is stable';
    }
  }

  /// Gets the trend direction as a simple string
  String get directionText {
    switch (trendDirection) {
      case WeightTrendDirection.increasing:
        return 'Increasing';
      case WeightTrendDirection.decreasing:
        return 'Decreasing';
      case WeightTrendDirection.stable:
        return 'Stable';
    }
  }

  /// Gets confidence level as text
  String get confidenceText {
    switch (confidence) {
      case WeightTrendConfidence.low:
        return 'Low confidence';
      case WeightTrendConfidence.medium:
        return 'Medium confidence';
      case WeightTrendConfidence.high:
        return 'High confidence';
    }
  }

  /// Checks if the trend is significant (not just noise)
  bool get isSignificant {
    return confidence != WeightTrendConfidence.low && 
           trendDirection != WeightTrendDirection.stable;
  }

  /// Gets weekly change formatted as text
  String get weeklyChangeText {
    final absChange = averageWeeklyChange.abs();
    final direction = averageWeeklyChange >= 0 ? '+' : '-';
    return '$direction${absChange.toStringAsFixed(2)} kg/week';
  }

  /// Gets total change formatted as text
  String get totalChangeText {
    final absChange = totalChange.abs();
    final direction = totalChange >= 0 ? '+' : '-';
    return '$direction${absChange.toStringAsFixed(2)} kg';
  }

  @override
  List<Object?> get props => [
        trendDirection,
        averageWeeklyChange,
        totalChange,
        confidence,
        dataPoints,
      ];
}

enum WeightTrendDirection {
  increasing,
  decreasing,
  stable,
}

enum WeightTrendConfidence {
  low,
  medium,
  high,
}