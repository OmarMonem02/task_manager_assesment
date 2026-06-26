import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.completed,
    required super.projectId,
    required super.userId,
    required super.description,
    required super.status,
    required super.priority,
    required super.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final completed = json['completed'] ?? false;
    return TaskModel(
      id: _parseInt(json['id']),
      title: json['title'] ?? json['name'] ?? '',
      completed: completed,
      projectId: _parseInt(json['projectId']),
      userId: _parseInt(json['userId'] ?? json['userID']),
      status: completed ? TaskStatus.done : TaskStatus.pending,
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      dueDate: _parseInt(json['dueDate']),
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
      'title': title,
      'completed': completed,
      'projectId': projectId,
      'userID': userId,
      "description": description,
      "status": status,
      "priority": priority,
      "dueDate": dueDate,
    };
  }
}
