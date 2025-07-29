import 'package:equatable/equatable.dart';

class CustomModelEntity extends Equatable {
  final String identifier;
  final String displayName;
  final DateTime addedAt;
  final bool isActive;

  const CustomModelEntity({
    required this.identifier,
    required this.displayName,
    required this.addedAt,
    this.isActive = false,
  });

  @override
  List<Object?> get props => [identifier, displayName, addedAt, isActive];

  String get shortName {
    final parts = identifier.split('/');
    return parts.isNotEmpty ? parts.last : identifier;
  }

  String get fullDisplayName {
    return displayName.isNotEmpty ? displayName : shortName;
  }

  CustomModelEntity copyWith({
    String? identifier,
    String? displayName,
    DateTime? addedAt,
    bool? isActive,
  }) {
    return CustomModelEntity(
      identifier: identifier ?? this.identifier,
      displayName: displayName ?? this.displayName,
      addedAt: addedAt ?? this.addedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'displayName': displayName,
      'addedAt': addedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory CustomModelEntity.fromJson(Map<String, dynamic> json) {
    return CustomModelEntity(
      identifier: json['identifier'] as String,
      displayName: json['displayName'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
} 