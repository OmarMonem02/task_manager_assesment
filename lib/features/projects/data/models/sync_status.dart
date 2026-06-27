enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
}

extension SyncStatusX on SyncStatus {
  String get name => toString().split('.').last;

  static SyncStatus fromName(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SyncStatus.synced,
    );
  }
}
