import '../entities/task_entity.dart';

enum ProjectDisplayStatus { pending, inProgress, completed }

class ProjectStatusHelper {
  static ProjectDisplayStatus fromTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return ProjectDisplayStatus.pending;
    if (tasks.every((t) => t.status == TaskStatus.done)) {
      return ProjectDisplayStatus.completed;
    }
    if (tasks.every((t) => t.status == TaskStatus.pending)) {
      return ProjectDisplayStatus.pending;
    }
    if (tasks.any((t) => t.status == TaskStatus.inProgress)) {
      return ProjectDisplayStatus.inProgress;
    }
    return ProjectDisplayStatus.inProgress;
  }

  static String label(ProjectDisplayStatus status) {
    switch (status) {
      case ProjectDisplayStatus.completed:
        return 'Completed';
      case ProjectDisplayStatus.inProgress:
        return 'In Progress';
      case ProjectDisplayStatus.pending:
        return 'Pending';
    }
  }
}
