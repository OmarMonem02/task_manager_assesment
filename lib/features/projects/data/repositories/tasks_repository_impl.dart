import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/projects_local_datasource.dart';
import '../datasources/sync_queue_local_datasource.dart';
import '../datasources/tasks_local_datasource.dart';
import '../datasources/tasks_remote_datasource.dart';
import '../models/local_task_record.dart';
import '../models/sync_queue_entry.dart';
import '../models/sync_status.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({
    required TasksRemoteDataSource remoteDataSource,
    required TasksLocalDataSource localDataSource,
    required ProjectsLocalDataSource projectsLocalDataSource,
    required SyncQueueLocalDataSource syncQueueLocalDataSource,
    required ConnectivityService connectivityService,
    required SessionStorage sessionStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _projectsLocalDataSource = projectsLocalDataSource,
        _syncQueueLocalDataSource = syncQueueLocalDataSource,
        _connectivityService = connectivityService,
        _sessionStorage = sessionStorage;

  final TasksRemoteDataSource _remoteDataSource;
  final TasksLocalDataSource _localDataSource;
  final ProjectsLocalDataSource _projectsLocalDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final ConnectivityService _connectivityService;
  final SessionStorage _sessionStorage;

  Future<int> _requireUserId() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return userId;
  }

  Future<bool> _canUseRemoteForProject(int userId, int projectId) async {
    if (!await _connectivityService.isOnline) return false;
    final project = await _projectsLocalDataSource.getProject(userId, projectId);
    return project != null &&
        project.syncStatus == SyncStatus.synced &&
        projectId > 0;
  }

  @override
  Future<List<TaskEntity>> getProjectTasks(int projectId) {
    return safeCall(() async {
      final userId = await _requireUserId();

      if (await _connectivityService.isOnline) {
        try {
          final remoteModels =
              await _remoteDataSource.getProjectTasks(projectId);
          await _localDataSource.upsertRemoteTasks(
            userId,
            projectId,
            remoteModels,
          );
        } catch (_) {
          // Fall back to local cache when remote refresh fails.
        }
      }

      final localTasks =
          await _localDataSource.getProjectTasks(userId, projectId);
      return localTasks.map((task) => task.toEntity()).toList();
    });
  }

  @override
  Future<TaskEntity> addTask({
    required String title,
    required int projectId,
    String priority = 'Medium',
  }) {
    return safeCall(() async {
      final userId = await _requireUserId();
      final project =
          await _projectsLocalDataSource.getProject(userId, projectId);
      if (project == null) {
        throw Exception('Project not found');
      }

      if (await _canUseRemoteForProject(userId, projectId)) {
        final model = await _remoteDataSource.addTask(
          title: title,
          projectId: projectId,
          priority: priority,
        );
        await _localDataSource.saveTask(
          LocalTaskRecord(
            id: model.id,
            title: model.title,
            completed: model.completed,
            projectId: model.projectId,
            userId: model.userId,
            status: model.status,
            description: model.description,
            priority: model.priority,
            dueDate: model.dueDate,
            syncStatus: SyncStatus.synced,
          ),
        );
        return model.toEntity();
      }

      final localId = await _localDataSource.nextLocalTaskId(userId);
      final dueDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final record = LocalTaskRecord(
        id: localId,
        title: title,
        completed: false,
        projectId: projectId,
        userId: userId,
        status: TaskStatus.pending,
        description: '',
        priority: priority,
        dueDate: dueDate,
        syncStatus: SyncStatus.pendingCreate,
      );
      await _localDataSource.saveTask(record);
      await _syncQueueLocalDataSource.addEntry(
        SyncQueueEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_task_create',
          userId: userId,
          entityType: SyncEntityType.task,
          operation: SyncOperation.create,
          localEntityId: localId,
          projectId: projectId,
          payload: {
            'title': title,
            'projectId': projectId,
            'priority': priority,
            'dueDate': dueDate,
          },
          createdAt: dueDate,
        ),
      );
      return record.toEntity();
    });
  }

  @override
  Future<TaskEntity> markTaskDone(int taskId) {
    return safeCall(() async {
      final userId = await _requireUserId();
      final task = await _localDataSource.getTask(userId, taskId);
      if (task == null) {
        throw Exception('Task not found');
      }

      if (await _canUseRemoteForProject(userId, task.projectId) &&
          task.syncStatus == SyncStatus.synced) {
        final model = await _remoteDataSource.markTaskDone(taskId);
        await _localDataSource.saveTask(
          LocalTaskRecord(
            id: model.id,
            title: model.title,
            completed: model.completed,
            projectId: model.projectId,
            userId: model.userId,
            status: model.status,
            description: model.description,
            priority: model.priority,
            dueDate: model.dueDate,
            syncStatus: SyncStatus.synced,
          ),
        );
        return model.toEntity();
      }

      final updated = task.copyWith(
        completed: true,
        status: TaskStatus.done,
        syncStatus: task.syncStatus == SyncStatus.pendingCreate
            ? SyncStatus.pendingCreate
            : SyncStatus.pendingUpdate,
      );
      await _localDataSource.saveTask(updated);

      if (task.syncStatus != SyncStatus.pendingCreate) {
        await _syncQueueLocalDataSource.addEntry(
          SyncQueueEntry(
            id: '${DateTime.now().microsecondsSinceEpoch}_task_update',
            userId: userId,
            entityType: SyncEntityType.task,
            operation: SyncOperation.update,
            localEntityId: taskId,
            projectId: task.projectId,
            payload: {'taskId': taskId},
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        );
      }

      return updated.toEntity();
    });
  }

  @override
  Future<void> deleteTask({
    required int taskId,
    required int projectId,
  }) {
    return safeCall(() async {
      final userId = await _requireUserId();
      final task = await _localDataSource.getTask(userId, taskId);
      if (task == null) return;

      if (await _canUseRemoteForProject(userId, projectId) &&
          task.syncStatus == SyncStatus.synced) {
        await _remoteDataSource.deleteTask(
          taskId: taskId,
          projectId: projectId,
        );
        await _localDataSource.removeTask(userId, projectId, taskId);
        return;
      }

      if (task.syncStatus == SyncStatus.pendingCreate) {
        await _localDataSource.removeTask(userId, projectId, taskId);
        await _syncQueueLocalDataSource.removeEntriesForEntity(userId, taskId);
        return;
      }

      await _localDataSource.markPendingDelete(userId, projectId, taskId);
      await _syncQueueLocalDataSource.addEntry(
        SyncQueueEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_task_delete',
          userId: userId,
          entityType: SyncEntityType.task,
          operation: SyncOperation.delete,
          localEntityId: taskId,
          projectId: projectId,
          payload: {
            'taskId': taskId,
            'projectId': projectId,
          },
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
      );
    });
  }
}
