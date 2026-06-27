import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_local_datasource.dart';
import '../datasources/projects_remote_datasource.dart';
import '../datasources/sync_queue_local_datasource.dart';
import '../models/local_project_record.dart';
import '../models/sync_queue_entry.dart';
import '../models/sync_status.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({
    required ProjectsRemoteDataSource remoteDataSource,
    required ProjectsLocalDataSource localDataSource,
    required SyncQueueLocalDataSource syncQueueLocalDataSource,
    required ConnectivityService connectivityService,
    required SessionStorage sessionStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _syncQueueLocalDataSource = syncQueueLocalDataSource,
        _connectivityService = connectivityService,
        _sessionStorage = sessionStorage;

  final ProjectsRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final ConnectivityService _connectivityService;
  final SessionStorage _sessionStorage;

  @override
  Future<List<ProjectEntity>> getProjects({required int userId}) {
    return safeCall(() async {
      if (await _connectivityService.isOnline) {
        try {
          final remoteModels =
              await _remoteDataSource.getProjects(userId: userId);
          await _localDataSource.upsertRemoteProjects(userId, remoteModels);
        } catch (_) {
          // Fall back to local cache when remote refresh fails.
        }
      }

      final localProjects = await _localDataSource.getProjects(userId);
      return localProjects.map((project) => project.toEntity()).toList();
    });
  }

  @override
  Future<ProjectEntity> createProject({
    required int userId,
    required String name,
    required String description,
    String status = 'active',
  }) {
    return safeCall(() async {
      if (await _connectivityService.isOnline) {
        final model = await _remoteDataSource.createProject(
          userId: userId,
          name: name,
          description: description,
          status: status,
        );
        await _localDataSource.saveProject(
          LocalProjectRecord(
            id: model.id,
            name: model.name,
            userId: model.userId,
            createdAt: model.createdAt,
            description: model.description,
            status: model.status,
            syncStatus: SyncStatus.synced,
          ),
        );
        return model.toEntity();
      }

      final localId = await _localDataSource.nextLocalProjectId(userId);
      final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final record = LocalProjectRecord(
        id: localId,
        name: name,
        userId: userId,
        createdAt: createdAt,
        description: description,
        status: status,
        syncStatus: SyncStatus.pendingCreate,
      );
      await _localDataSource.saveProject(record);
      await _syncQueueLocalDataSource.addEntry(
        SyncQueueEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_project_create',
          userId: userId,
          entityType: SyncEntityType.project,
          operation: SyncOperation.create,
          localEntityId: localId,
          payload: {
            'name': name,
            'description': description,
            'status': status,
            'userId': userId,
            'createdAt': createdAt,
          },
          createdAt: createdAt,
        ),
      );
      return record.toEntity();
    });
  }

  @override
  Future<void> deleteProject(int projectId) {
    return safeCall(() async {
      final userId = await _sessionStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final project = await _localDataSource.getProject(userId, projectId);
      if (project == null) return;

      if (await _connectivityService.isOnline &&
          project.syncStatus == SyncStatus.synced) {
        await _remoteDataSource.deleteProject(projectId);
        await _localDataSource.removeProject(userId, projectId);
        return;
      }

      if (project.syncStatus == SyncStatus.pendingCreate) {
        await _localDataSource.removeProject(userId, projectId);
        await _syncQueueLocalDataSource.removeEntriesForEntity(
          userId,
          projectId,
        );
        return;
      }

      await _localDataSource.markPendingDelete(userId, projectId);
      await _syncQueueLocalDataSource.addEntry(
        SyncQueueEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_project_delete',
          userId: userId,
          entityType: SyncEntityType.project,
          operation: SyncOperation.delete,
          localEntityId: projectId,
          payload: {'projectId': projectId},
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
      );
    });
  }
}
