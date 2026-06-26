import '../entities/task_entity.dart';

abstract class TasksRepository {
  Future<List<TaskEntity>> getProjectTasks(int projectId);
  Future<TaskEntity> addTask({
    required String title,
    required int projectId,
    String priority,
  });
  Future<TaskEntity> markTaskDone(int taskId);
  Future<void> deleteTask({required int taskId, required int projectId});
}
