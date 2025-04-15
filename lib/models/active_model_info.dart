// lib/models/active_model_info.dart
class ActiveModelInfo {
  final String? id;
  final String? name;
  final String? repoUrl;
  final String? description;

  ActiveModelInfo({
    this.id,
    this.name,
    this.repoUrl,
    this.description,
  });

  // Factory constructor to create an instance from JSON
  factory ActiveModelInfo.fromJson(Map<String, dynamic> json) {
    return ActiveModelInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      repoUrl: json['repo_url'] as String?,
      description: json['description'] as String?,
    );
  }
}