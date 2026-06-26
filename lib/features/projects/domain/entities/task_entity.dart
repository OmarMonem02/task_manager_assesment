import 'package:equatable/equatable.dart';

enum TaskStatus { pending, inProgress, done }

class TaskEntity extends Equatable {
  final int id;
  final String title;
  final bool completed;
  final int projectId;
  final int userId;
  final TaskStatus status;
  final String description;
  final String priority;
  final int dueDate;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.completed,
    required this.projectId,
    required this.userId,
    this.status = TaskStatus.pending,
    required this.description,
    required this.priority,
    required this.dueDate,
  });

  TaskEntity copyWith({
    int? id,
    String? title,
    bool? completed,
    int? projectId,
    int? userId,
    TaskStatus? status,
    String? description,
    String? priority,
    int? dueDate,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, title, completed, projectId, userId, status, description, priority, dueDate];
}