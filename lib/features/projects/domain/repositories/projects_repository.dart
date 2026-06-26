import '../entities/project_entity.dart';
import '../entities/task_entity.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> getProjects({required int userId});
  Future<ProjectEntity> createProject({
    required int userId,
    required String name,
    required String description,
    String status = 'active',
  });
  Future<void> deleteProject(int projectId);
  Future<List<TaskEntity>> getProjectTasks(int projectId);
  Future<TaskEntity> addTask({
    required String title,
    required int projectId,
    String priority,
  });
  Future<TaskEntity> markTaskDone(int taskId);
  Future<void> deleteTask({required int taskId, required int projectId});
}