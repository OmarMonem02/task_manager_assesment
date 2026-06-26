import '../../domain/entities/task_entity.dart';

extension TaskListExtensions on List<TaskEntity> {
  int get doneCount => where((t) => t.status == TaskStatus.done).length;

  double get progress => isEmpty ? 0 : doneCount / length;
}
