import '../../domain/entities/project_entity.dart';

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.description,
    required this.status,
  });

  final int id;
  final String name;
  final int userId;
  final int createdAt;
  final String description;
  final String status;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      userId: _parseInt(json['userId'] ?? json['userID']),
      createdAt: _parseInt(json['createdAt']),
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      userId: entity.userId,
      createdAt: entity.createdAt,
      description: entity.description,
      status: entity.status,
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      userId: userId,
      createdAt: createdAt,
      description: description,
      status: status,
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
