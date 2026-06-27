import '../datasources/projects_local_datasource.dart';
import '../datasources/sync_queue_local_datasource.dart';
import '../datasources/tasks_local_datasource.dart';

class UserProjectsStorageCleaner {
  UserProjectsStorageCleaner({
    required ProjectsLocalDataSource projectsLocalDataSource,
    required TasksLocalDataSource tasksLocalDataSource,
    required SyncQueueLocalDataSource syncQueueLocalDataSource,
  })  : _projectsLocalDataSource = projectsLocalDataSource,
        _tasksLocalDataSource = tasksLocalDataSource,
        _syncQueueLocalDataSource = syncQueueLocalDataSource;

  final ProjectsLocalDataSource _projectsLocalDataSource;
  final TasksLocalDataSource _tasksLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;

  Future<void> clearUserData(int userId) async {
    await _projectsLocalDataSource.clearUserData(userId);
    await _tasksLocalDataSource.clearUserData(userId);
    await _syncQueueLocalDataSource.clearUserData(userId);
  }
}
