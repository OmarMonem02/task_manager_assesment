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

  @override
  List<Object?> get props => [id, name, userId, createdAt, description, status];
}