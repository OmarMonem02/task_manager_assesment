import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String name;
  final int userId;
  final int createdAt;
  final String description;
  final String status;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.description,
    required this.status,
  });

  ProjectEntity copyWith({
    int? id,
    String? name,
    int? userId,
    int? createdAt,
    String? description,
    String? status,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, name, userId, createdAt, description, status];
}