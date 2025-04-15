// lib/models/model_info.dart
import 'package:flutter/foundation.dart' show immutable; // For @immutable

@immutable // Good practice for model classes
class ModelInfo {
  final String id;
  final String repoUrl;
  final String name;
  final String? description;
  final bool installed;
  final bool active;

  const ModelInfo({
    required this.id,
    required this.repoUrl,
    required this.name,
    this.description,
    required this.installed,
    required this.active,
  });

  // Factory constructor to create an instance from JSON
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String? ?? 'unknown_id', // Provide default or handle error
      repoUrl: json['repo_url'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Model', // Provide default
      description: json['description'] as String?,
      installed: json['installed'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
    );
  }
}