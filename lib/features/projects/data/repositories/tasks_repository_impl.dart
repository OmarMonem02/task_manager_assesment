import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_remote_datasource.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({required TasksRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final TasksRemoteDataSource _remoteDataSource;

  @override
  Future<List<TaskEntity>> getProjectTasks(int projectId) {
    return safeCall(() async {
      final models = await _remoteDataSource.getProjectTasks(projectId);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<TaskEntity> addTask({
    required String title,
    required int projectId,
    String priority = 'Medium',
  }) {
    return safeCall(() async {
      final model = await _remoteDataSource.addTask(
        title: title,
        projectId: projectId,
        priority: priority,
      );
      return model.toEntity();
    });
  }

  @override
  Future<TaskEntity> markTaskDone(int taskId) {
    return safeCall(() async {
      final model = await _remoteDataSource.markTaskDone(taskId);
      return model.toEntity();
    });
  }

  @override
  Future<void> deleteTask({
    required int taskId,
    required int projectId,
  }) {
    return safeCall(
      () => _remoteDataSource.deleteTask(
        taskId: taskId,
        projectId: projectId,
      ),
    );
  }
}
