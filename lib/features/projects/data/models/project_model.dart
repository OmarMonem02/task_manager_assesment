import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.userId,
    required super.createdAt,
    required super.description,
    required super.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      userId: _parseInt(json['userId']),
      createdAt: _parseInt(json['createdAt']),
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }

  static int _parseInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt,
      'description': description,
      'status': status,
    };
  }
}
