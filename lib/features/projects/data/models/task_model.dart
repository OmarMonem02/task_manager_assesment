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
    final completed = json['completed'] == true;
    return TaskModel(
      id: _parseInt(json['id']),
      title: json['title'] ?? json['name'] ?? '',
      completed: completed,
      projectId: _parseInt(json['projectId']),
      userId: _parseInt(json['userId'] ?? json['userID']),
      status: _parseStatus(json['status'], completed),
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      dueDate: _parseInt(json['dueDate']),
    );
  }

  static TaskStatus _parseStatus(dynamic value, bool completed) {
    if (completed) return TaskStatus.done;
    final normalized = value?.toString().toLowerCase() ?? '';
    if (normalized.contains('progress')) return TaskStatus.inProgress;
    if (normalized == 'done' || normalized == 'completed') {
      return TaskStatus.done;
    }
    return TaskStatus.pending;
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
      'description': description,
      'status': _statusToString(status),
      'priority': priority,
      'dueDate': dueDate,
    };
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
    }
  }
}
