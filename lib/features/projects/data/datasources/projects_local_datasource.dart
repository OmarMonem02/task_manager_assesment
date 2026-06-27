import '../../../../core/storage/hive_storage.dart';
import '../models/local_project_record.dart';
import '../models/project_model.dart';
import '../models/sync_status.dart';

abstract class ProjectsLocalDataSource {
  Future<List<LocalProjectRecord>> getProjects(int userId);
  Future<LocalProjectRecord?> getProject(int userId, int projectId);
  Future<void> saveProject(LocalProjectRecord project);
  Future<void> removeProject(int userId, int projectId);
  Future<void> markPendingDelete(int userId, int projectId);
  Future<int> nextLocalProjectId(int userId);
  Future<void> replaceProjectId({
    required int userId,
    required int oldId,
    required LocalProjectRecord updatedProject,
  });
  Future<Set<int>> expandProjectIds(int userId, int projectId);
  Future<void> upsertRemoteProjects(int userId, List<ProjectModel> remoteProjects);
  Future<void> clearUserData(int userId);
}

class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceImpl();

  String _key(int userId, int projectId) => 'p_${userId}_$projectId';

  String _userPrefix(int userId) => 'p_${userId}_';

  String _nextIdKey(int userId) => 'next_project_id_$userId';

  String _projectMapKey(int userId, int oldId) => 'project_map_${userId}_$oldId';

  @override
  Future<List<LocalProjectRecord>> getProjects(int userId) async {
    final box = HiveStorage.projectsBox;
    final prefix = _userPrefix(userId);
    final projects = <LocalProjectRecord>[];

    for (final key in box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = box.get(key);
      if (raw is! Map) continue;
      final record = LocalProjectRecord.fromJson(raw);
      if (record.syncStatus == SyncStatus.pendingDelete) continue;
      projects.add(record);
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  @override
  Future<LocalProjectRecord?> getProject(int userId, int projectId) async {
    final raw = HiveStorage.projectsBox.get(_key(userId, projectId));
    if (raw is! Map) return null;
    return LocalProjectRecord.fromJson(raw);
  }

  @override
  Future<void> saveProject(LocalProjectRecord project) async {
    await HiveStorage.projectsBox.put(
      _key(project.userId, project.id),
      project.toJson(),
    );
  }

  @override
  Future<void> removeProject(int userId, int projectId) async {
    await HiveStorage.projectsBox.delete(_key(userId, projectId));
  }

  @override
  Future<void> markPendingDelete(int userId, int projectId) async {
    final project = await getProject(userId, projectId);
    if (project == null) return;
    await saveProject(project.copyWith(syncStatus: SyncStatus.pendingDelete));
  }

  @override
  Future<int> nextLocalProjectId(int userId) async {
    final box = HiveStorage.metaBox;
    final key = _nextIdKey(userId);
    final current = box.get(key) as int? ?? 0;
    final next = current == 0 ? -1 : current - 1;
    await box.put(key, next);
    return next;
  }

  @override
  Future<void> replaceProjectId({
    required int userId,
    required int oldId,
    required LocalProjectRecord updatedProject,
  }) async {
    await HiveStorage.metaBox.put(
      _projectMapKey(userId, oldId),
      updatedProject.id,
    );
    await HiveStorage.projectsBox.delete(_key(userId, oldId));
    await saveProject(updatedProject);
  }

  @override
  Future<Set<int>> expandProjectIds(int userId, int projectId) async {
    final ids = <int>{projectId};
    final project = await getProject(userId, projectId);
    if (project != null) {
      ids.add(project.id);
    }

    var current = projectId;
    while (true) {
      final mapped = HiveStorage.metaBox.get(_projectMapKey(userId, current));
      if (mapped is! int) break;
      ids.add(mapped);
      current = mapped;
    }

    return ids;
  }

  @override
  Future<void> upsertRemoteProjects(
    int userId,
    List<ProjectModel> remoteProjects,
  ) async {
    final pendingProjects = (await getProjectsIncludingDeleted(userId))
        .where((project) => project.syncStatus != SyncStatus.synced)
        .toList();

    for (final key in HiveStorage.projectsBox.keys.toList()) {
      if (key is! String || !key.startsWith(_userPrefix(userId))) continue;
      final raw = HiveStorage.projectsBox.get(key);
      if (raw is! Map) continue;
      final record = LocalProjectRecord.fromJson(raw);
      if (record.syncStatus == SyncStatus.synced) {
        await HiveStorage.projectsBox.delete(key);
      }
    }

    for (final model in remoteProjects) {
      await saveProject(
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
    }

    for (final pending in pendingProjects) {
      if (pending.syncStatus == SyncStatus.pendingDelete) {
        await saveProject(pending);
      } else {
        await saveProject(pending);
      }
    }
  }

  Future<List<LocalProjectRecord>> getProjectsIncludingDeleted(int userId) async {
    final box = HiveStorage.projectsBox;
    final prefix = _userPrefix(userId);
    final projects = <LocalProjectRecord>[];

    for (final key in box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = box.get(key);
      if (raw is! Map) continue;
      projects.add(LocalProjectRecord.fromJson(raw));
    }

    return projects;
  }

  @override
  Future<void> clearUserData(int userId) async {
    final prefix = _userPrefix(userId);
    for (final key in HiveStorage.projectsBox.keys.toList()) {
      if (key is String && key.startsWith(prefix)) {
        await HiveStorage.projectsBox.delete(key);
      }
    }
    await HiveStorage.metaBox.delete(_nextIdKey(userId));
  }
}
