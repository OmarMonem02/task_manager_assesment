import '../../../../core/storage/hive_storage.dart';
import '../models/local_task_record.dart';
import '../models/sync_status.dart';
import '../models/task_model.dart';

abstract class TasksLocalDataSource {
  Future<List<LocalTaskRecord>> getProjectTasks(int userId, int projectId);
  Future<List<LocalTaskRecord>> getTasksForProjects(
    int userId,
    Set<int> projectIds,
  );
  Future<LocalTaskRecord?> getTask(int userId, int taskId);
  Future<void> saveTask(LocalTaskRecord task);
  Future<void> removeTask(int userId, int projectId, int taskId);
  Future<void> markPendingDelete(int userId, int projectId, int taskId);
  Future<int> nextLocalTaskId(int userId);
  Future<void> replaceTaskId({
    required int userId,
    required int projectId,
    required int oldId,
    required LocalTaskRecord updatedTask,
  });
  Future<void> remapProjectId(int userId, int oldProjectId, int newProjectId);
  Future<void> upsertRemoteTasks(
    int userId,
    int projectId,
    List<TaskModel> remoteTasks, {
    Set<int> preserveSyncedTaskIds = const {},
    bool reconcileDeletions = false,
  });
  Future<void> clearUserData(int userId);
}

class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  TasksLocalDataSourceImpl();

  String _key(int userId, int projectId, int taskId) =>
      't_${userId}_${projectId}_$taskId';

  String _projectPrefix(int userId, int projectId) => 't_${userId}_${projectId}_';

  String _userPrefix(int userId) => 't_${userId}_';

  String _nextIdKey(int userId) => 'next_task_id_$userId';

  int? _taskIdFromKey(String key) {
    if (!key.startsWith('t_')) return null;
    final lastSeparator = key.lastIndexOf('_');
    if (lastSeparator <= 2) return null;
    return int.tryParse(key.substring(lastSeparator + 1));
  }

  @override
  Future<List<LocalTaskRecord>> getProjectTasks(
    int userId,
    int projectId,
  ) {
    return getTasksForProjects(userId, {projectId});
  }

  @override
  Future<List<LocalTaskRecord>> getTasksForProjects(
    int userId,
    Set<int> projectIds,
  ) async {
    if (projectIds.isEmpty) return [];

    final box = HiveStorage.tasksBox;
    final tasks = <LocalTaskRecord>[];

    for (final key in box.keys.toList()) {
      if (key is! String || !key.startsWith('t_')) continue;
      final raw = box.get(key);
      if (raw is! Map) continue;

      var record = LocalTaskRecord.fromJson(raw);
      if (record.syncStatus == SyncStatus.pendingDelete) continue;
      if (!projectIds.contains(record.projectId)) continue;

      final belongsToUser =
          record.userId == userId || record.userId == 0;
      if (!belongsToUser) continue;

      if (record.userId == 0) {
        record = record.copyWith(userId: userId);
      }

      final canonicalKey = _key(record.userId, record.projectId, record.id);
      if (key != canonicalKey) {
        await box.delete(key);
      }
      await saveTask(record);
      tasks.add(record);
    }

    return tasks;
  }

  @override
  Future<LocalTaskRecord?> getTask(int userId, int taskId) async {
    for (final key in HiveStorage.tasksBox.keys) {
      if (key is! String || !key.startsWith('t_')) continue;
      if (_taskIdFromKey(key) != taskId) continue;
      final raw = HiveStorage.tasksBox.get(key);
      if (raw is! Map) continue;

      var record = LocalTaskRecord.fromJson(raw);
      if (record.userId != userId && record.userId != 0) continue;

      if (record.userId == 0) {
        record = record.copyWith(userId: userId);
        final canonicalKey = _key(record.userId, record.projectId, record.id);
        if (key != canonicalKey) {
          await HiveStorage.tasksBox.delete(key);
        }
        await saveTask(record);
      }

      return record;
    }

    return null;
  }

  @override
  Future<void> saveTask(LocalTaskRecord task) async {
    await HiveStorage.tasksBox.put(
      _key(task.userId, task.projectId, task.id),
      task.toJson(),
    );
  }

  @override
  Future<void> removeTask(int userId, int projectId, int taskId) async {
    await HiveStorage.tasksBox.delete(_key(userId, projectId, taskId));
  }

  @override
  Future<void> markPendingDelete(int userId, int projectId, int taskId) async {
    final task = await getTask(userId, taskId);
    if (task == null) return;
    await saveTask(task.copyWith(syncStatus: SyncStatus.pendingDelete));
  }

  @override
  Future<int> nextLocalTaskId(int userId) async {
    final box = HiveStorage.metaBox;
    final key = _nextIdKey(userId);
    final current = box.get(key) as int? ?? 0;
    final next = current == 0 ? -1 : current - 1;
    await box.put(key, next);
    return next;
  }

  @override
  Future<void> replaceTaskId({
    required int userId,
    required int projectId,
    required int oldId,
    required LocalTaskRecord updatedTask,
  }) async {
    final prefix = _userPrefix(userId);
    for (final key in HiveStorage.tasksBox.keys.toList()) {
      if (key is! String || !key.startsWith(prefix)) continue;
      if (_taskIdFromKey(key) != oldId) continue;
      await HiveStorage.tasksBox.delete(key);
      break;
    }
    await saveTask(updatedTask);
  }

  @override
  Future<void> remapProjectId(
    int userId,
    int oldProjectId,
    int newProjectId,
  ) async {
    final prefix = _projectPrefix(userId, oldProjectId);
    final entries = <String, LocalTaskRecord>{};

    for (final key in HiveStorage.tasksBox.keys.toList()) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = HiveStorage.tasksBox.get(key);
      if (raw is! Map) continue;
      final record = LocalTaskRecord.fromJson(raw);
      entries[key] = record.copyWith(projectId: newProjectId);
      await HiveStorage.tasksBox.delete(key);
    }

    for (final record in entries.values) {
      await saveTask(record);
    }
  }

  @override
  Future<void> upsertRemoteTasks(
    int userId,
    int projectId,
    List<TaskModel> remoteTasks, {
    Set<int> preserveSyncedTaskIds = const {},
    bool reconcileDeletions = false,
  }) async {
    final remoteIds = remoteTasks.map((task) => task.id).toSet();

    if (reconcileDeletions) {
      for (final key in HiveStorage.tasksBox.keys.toList()) {
        if (key is! String || !key.startsWith('t_')) continue;
        final raw = HiveStorage.tasksBox.get(key);
        if (raw is! Map) continue;
        final record = LocalTaskRecord.fromJson(raw);
        if (record.projectId != projectId) continue;
        if (record.userId != userId && record.userId != 0) continue;
        if (record.syncStatus == SyncStatus.synced &&
            !remoteIds.contains(record.id) &&
            !preserveSyncedTaskIds.contains(record.id)) {
          await HiveStorage.tasksBox.delete(key);
        }
      }
    }

    for (final model in remoteTasks) {
      if (model.projectId != projectId) continue;
      final existing = await getTask(userId, model.id);
      if (existing != null && existing.syncStatus != SyncStatus.synced) {
        continue;
      }
      await saveTask(
        LocalTaskRecord.fromRemote(model, userId: userId),
      );
    }
  }

  @override
  Future<void> clearUserData(int userId) async {
    final prefix = _userPrefix(userId);
    for (final key in HiveStorage.tasksBox.keys.toList()) {
      if (key is String && key.startsWith(prefix)) {
        await HiveStorage.tasksBox.delete(key);
      }
    }
    await HiveStorage.metaBox.delete(_nextIdKey(userId));
  }
}
