import '../entities/project_entity.dart';
import '../entities/task_entity.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<List<TaskEntity>> getProjectTasks(int projectId);
  Future<TaskEntity> addTask({required String title, required int projectId});
  Future<TaskEntity> markTaskDone(int taskId);
}