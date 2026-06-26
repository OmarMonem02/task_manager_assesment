import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.completed,
    required super.projectId,
    required super.userId,
    super.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final completed = json['completed'] ?? false;
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      completed: completed,
      projectId: json['albumId'] ?? json['projectId'] ?? 0,
      userId: json['userId'] ?? 0,
      status: completed ? TaskStatus.done : TaskStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'albumId': projectId,
      'userId': userId,
    };
  }
}