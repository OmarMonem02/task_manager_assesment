import '../entities/sync_result.dart';
import '../repositories/sync_repository.dart';

class SyncProjectsUseCase {
  SyncProjectsUseCase(this._syncRepository);

  final SyncRepository _syncRepository;

  Future<SyncResult> call(int userId) => _syncRepository.syncProjects(userId);
}

class GetPendingSyncCountUseCase {
  GetPendingSyncCountUseCase(this._syncRepository);

  final SyncRepository _syncRepository;

  Future<int> call(int userId) => _syncRepository.getPendingSyncCount(userId);
}
