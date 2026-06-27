import '../../../../core/storage/hive_storage.dart';
import '../models/sync_queue_entry.dart';

abstract class SyncQueueLocalDataSource {
  Future<void> addEntry(SyncQueueEntry entry);
  Future<List<SyncQueueEntry>> getEntries(int userId);
  Future<int> getPendingCount(int userId);
  Future<void> removeEntry(String entryId);
  Future<void> removeEntriesForEntity(int userId, int localEntityId);
  Future<void> updateEntryLocalEntityId({
    required String entryId,
    required int newLocalEntityId,
    int? newProjectId,
  });
  Future<void> clearUserData(int userId);
}

class SyncQueueLocalDataSourceImpl implements SyncQueueLocalDataSource {
  SyncQueueLocalDataSourceImpl();

  String _key(int userId, String entryId) => 's_${userId}_$entryId';

  String _userPrefix(int userId) => 's_${userId}_';

  @override
  Future<void> addEntry(SyncQueueEntry entry) async {
    await HiveStorage.syncQueueBox.put(
      _key(entry.userId, entry.id),
      entry.toJson(),
    );
  }

  @override
  Future<List<SyncQueueEntry>> getEntries(int userId) async {
    final prefix = _userPrefix(userId);
    final entries = <SyncQueueEntry>[];

    for (final key in HiveStorage.syncQueueBox.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final raw = HiveStorage.syncQueueBox.get(key);
      if (raw is! Map) continue;
      entries.add(SyncQueueEntry.fromJson(raw));
    }

    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }

  @override
  Future<int> getPendingCount(int userId) async {
    final entries = await getEntries(userId);
    return entries.length;
  }

  @override
  Future<void> removeEntry(String entryId) async {
    for (final key in HiveStorage.syncQueueBox.keys.toList()) {
      if (key is! String || !key.endsWith('_$entryId')) continue;
      await HiveStorage.syncQueueBox.delete(key);
      return;
    }
  }

  @override
  Future<void> removeEntriesForEntity(int userId, int localEntityId) async {
    final entries = await getEntries(userId);
    for (final entry in entries) {
      if (entry.localEntityId == localEntityId) {
        await removeEntry(entry.id);
      }
    }
  }

  @override
  Future<void> updateEntryLocalEntityId({
    required String entryId,
    required int newLocalEntityId,
    int? newProjectId,
  }) async {
    for (final key in HiveStorage.syncQueueBox.keys) {
      if (key is! String || !key.endsWith('_$entryId')) continue;
      final raw = HiveStorage.syncQueueBox.get(key);
      if (raw is! Map) continue;
      final entry = SyncQueueEntry.fromJson(raw);
      final updated = SyncQueueEntry(
        id: entry.id,
        userId: entry.userId,
        entityType: entry.entityType,
        operation: entry.operation,
        localEntityId: newLocalEntityId,
        payload: {
          ...entry.payload,
          if (newProjectId != null) 'projectId': newProjectId,
        },
        createdAt: entry.createdAt,
        projectId: newProjectId ?? entry.projectId,
      );
      await HiveStorage.syncQueueBox.put(key, updated.toJson());
      return;
    }
  }

  @override
  Future<void> clearUserData(int userId) async {
    final prefix = _userPrefix(userId);
    for (final key in HiveStorage.syncQueueBox.keys.toList()) {
      if (key is String && key.startsWith(prefix)) {
        await HiveStorage.syncQueueBox.delete(key);
      }
    }
  }
}
