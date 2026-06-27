import '../entities/sync_result.dart';

abstract class SyncRepository {
  Future<SyncResult> syncProjects(int userId);
  Future<int> getPendingSyncCount(int userId);
}
