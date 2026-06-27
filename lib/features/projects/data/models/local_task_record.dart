import 'task_model.dart';
import '../../domain/entities/task_entity.dart';
import 'sync_status.dart';

class LocalTaskRecord {
  const LocalTaskRecord({
    required this.id,
    required this.title,
    required this.completed,
    required this.projectId,
    required this.userId,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.syncStatus = SyncStatus.synced,
  });

  final int id;
  final String title;
  final bool completed;
  final int projectId;
  final int userId;
  final TaskStatus status;
  final String description;
  final String priority;
  final int dueDate;
  final SyncStatus syncStatus;

  factory LocalTaskRecord.fromJson(Map<dynamic, dynamic> json) {
    return LocalTaskRecord(
      id: _parseInt(json['id']),
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      projectId: _parseInt(json['projectId']),
      userId: _parseInt(json['userId']),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      dueDate: _parseInt(json['dueDate']),
      syncStatus: SyncStatusX.fromName(json['syncStatus'] as String? ?? 'synced'),
    );
  }

  factory LocalTaskRecord.fromRemote(
    TaskModel model, {
    required int userId,
    SyncStatus syncStatus = SyncStatus.synced,
  }) {
    return LocalTaskRecord(
      id: model.id,
      title: model.title,
      completed: model.completed,
      projectId: model.projectId,
      userId: userId,
      status: model.status,
      description: model.description,
      priority: model.priority,
      dueDate: model.dueDate,
      syncStatus: syncStatus,
    );
  }

  static int _parseInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'projectId': projectId,
      'userId': userId,
      'status': status.name,
      'description': description,
      'priority': priority,
      'dueDate': dueDate,
      'syncStatus': syncStatus.name,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      completed: completed,
      projectId: projectId,
      userId: userId,
      status: status,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
  }

  LocalTaskRecord copyWith({
    int? id,
    String? title,
    bool? completed,
    int? projectId,
    int? userId,
    TaskStatus? status,
    String? description,
    String? priority,
    int? dueDate,
    SyncStatus? syncStatus,
  }) {
    return LocalTaskRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
