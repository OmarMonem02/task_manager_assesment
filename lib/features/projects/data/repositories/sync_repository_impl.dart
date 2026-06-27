import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/projects_local_datasource.dart';
import '../datasources/projects_remote_datasource.dart';
import '../datasources/sync_queue_local_datasource.dart';
import '../datasources/tasks_local_datasource.dart';
import '../datasources/tasks_remote_datasource.dart';
import '../models/local_project_record.dart';
import '../models/local_task_record.dart';
import '../models/sync_queue_entry.dart';
import '../models/sync_status.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required ProjectsRemoteDataSource projectsRemoteDataSource,
    required TasksRemoteDataSource tasksRemoteDataSource,
    required ProjectsLocalDataSource projectsLocalDataSource,
    required TasksLocalDataSource tasksLocalDataSource,
    required SyncQueueLocalDataSource syncQueueLocalDataSource,
    required ConnectivityService connectivityService,
  })  : _projectsRemoteDataSource = projectsRemoteDataSource,
        _tasksRemoteDataSource = tasksRemoteDataSource,
        _projectsLocalDataSource = projectsLocalDataSource,
        _tasksLocalDataSource = tasksLocalDataSource,
        _syncQueueLocalDataSource = syncQueueLocalDataSource,
        _connectivityService = connectivityService;

  final ProjectsRemoteDataSource _projectsRemoteDataSource;
  final TasksRemoteDataSource _tasksRemoteDataSource;
  final ProjectsLocalDataSource _projectsLocalDataSource;
  final TasksLocalDataSource _tasksLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final ConnectivityService _connectivityService;

  int _resolveProjectId(int localProjectId, Map<int, int> projectIdMap) {
    return projectIdMap[localProjectId] ?? localProjectId;
  }

  @override
  Future<int> getPendingSyncCount(int userId) {
    return _syncQueueLocalDataSource.getPendingCount(userId);
  }

  @override
  Future<SyncResult> syncProjects(int userId) {
    return safeCall(() async {
      if (!await _connectivityService.isOnline) {
        throw const NetworkException('You are offline');
      }

      final entries = await _syncQueueLocalDataSource.getEntries(userId);
      final projectIdMap = <int, int>{};
      var pushed = 0;
      var failed = 0;

      for (final entry in entries) {
        if (entry.entityType != SyncEntityType.project ||
            entry.operation != SyncOperation.create) {
          continue;
        }

        try {
          final model = await _projectsRemoteDataSource.createProject(
            userId: userId,
            name: entry.payload['name'] as String,
            description: entry.payload['description'] as String? ?? '',
            status: entry.payload['status'] as String? ?? 'active',
          );
          projectIdMap[entry.localEntityId] = model.id;
          await _projectsLocalDataSource.replaceProjectId(
            userId: userId,
            oldId: entry.localEntityId,
            updatedProject: LocalProjectRecord(
              id: model.id,
              name: model.name,
              userId: model.userId,
              createdAt: model.createdAt,
              description: model.description,
              status: model.status,
              syncStatus: SyncStatus.synced,
            ),
          );
          await _tasksLocalDataSource.remapProjectId(
            userId,
            entry.localEntityId,
            model.id,
          );
          await _syncQueueLocalDataSource.removeEntry(entry.id);
          pushed++;
        } catch (_) {
          failed++;
          return SyncResult(pushed: pushed, failed: failed);
        }
      }

      for (final entry in entries) {
        if (entry.entityType != SyncEntityType.task ||
            entry.operation != SyncOperation.create) {
          continue;
        }

        try {
          final localProjectId = entry.projectId ?? entry.payload['projectId'] as int;
          final remoteProjectId = _resolveProjectId(localProjectId, projectIdMap);
          final model = await _tasksRemoteDataSource.addTask(
            title: entry.payload['title'] as String,
            projectId: remoteProjectId,
            priority: entry.payload['priority'] as String? ?? 'Medium',
          );
          final localTask = await _tasksLocalDataSource.getTask(
            userId,
            entry.localEntityId,
          );
          var syncedTask = model;
          if (localTask != null && localTask.completed) {
            syncedTask = await _tasksRemoteDataSource.markTaskDone(model.id);
          }
          if (localTask != null) {
            await _tasksLocalDataSource.replaceTaskId(
              userId: userId,
              projectId: remoteProjectId,
              oldId: entry.localEntityId,
              updatedTask: LocalTaskRecord(
                id: syncedTask.id,
                title: syncedTask.title,
                completed: syncedTask.completed,
                projectId: syncedTask.projectId,
                userId: syncedTask.userId,
                status: syncedTask.status,
                description: syncedTask.description,
                priority: syncedTask.priority,
                dueDate: syncedTask.dueDate,
                syncStatus: SyncStatus.synced,
              ),
            );
          }
          await _syncQueueLocalDataSource.removeEntry(entry.id);
          pushed++;
        } catch (_) {
          failed++;
          return SyncResult(pushed: pushed, failed: failed);
        }
      }

      for (final entry in entries) {
        if (entry.entityType != SyncEntityType.task ||
            entry.operation != SyncOperation.update) {
          continue;
        }

        try {
          final taskId = entry.localEntityId;
          await _tasksRemoteDataSource.markTaskDone(taskId);
          final localTask = await _tasksLocalDataSource.getTask(userId, taskId);
          if (localTask != null) {
            await _tasksLocalDataSource.saveTask(
              localTask.copyWith(syncStatus: SyncStatus.synced),
            );
          }
          await _syncQueueLocalDataSource.removeEntry(entry.id);
          pushed++;
        } catch (_) {
          failed++;
          return SyncResult(pushed: pushed, failed: failed);
        }
      }

      for (final entry in entries) {
        if (entry.entityType != SyncEntityType.task ||
            entry.operation != SyncOperation.delete) {
          continue;
        }

        try {
          final taskId = entry.payload['taskId'] as int;
          final localProjectId = entry.payload['projectId'] as int;
          final remoteProjectId = _resolveProjectId(localProjectId, projectIdMap);
          await _tasksRemoteDataSource.deleteTask(
            taskId: taskId,
            projectId: remoteProjectId,
          );
          await _tasksLocalDataSource.removeTask(
            userId,
            remoteProjectId,
            taskId,
          );
          await _syncQueueLocalDataSource.removeEntry(entry.id);
          pushed++;
        } catch (_) {
          failed++;
          return SyncResult(pushed: pushed, failed: failed);
        }
      }

      for (final entry in entries) {
        if (entry.entityType != SyncEntityType.project ||
            entry.operation != SyncOperation.delete) {
          continue;
        }

        try {
          final projectId = entry.payload['projectId'] as int;
          await _projectsRemoteDataSource.deleteProject(projectId);
          await _projectsLocalDataSource.removeProject(userId, projectId);
          await _syncQueueLocalDataSource.removeEntry(entry.id);
          pushed++;
        } catch (_) {
          failed++;
          return SyncResult(pushed: pushed, failed: failed);
        }
      }

      await _pullRemoteData(userId);
      return SyncResult(pushed: pushed, failed: failed);
    });
  }

  Future<void> _pullRemoteData(int userId) async {
    final remoteProjects =
        await _projectsRemoteDataSource.getProjects(userId: userId);
    await _projectsLocalDataSource.upsertRemoteProjects(userId, remoteProjects);

    for (final project in remoteProjects) {
      final remoteTasks =
          await _tasksRemoteDataSource.getProjectTasks(project.id);
      await _tasksLocalDataSource.upsertRemoteTasks(
        userId,
        project.id,
        remoteTasks,
      );
    }
  }
}
