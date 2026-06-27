class SyncResult {
  const SyncResult({
    required this.pushed,
    required this.failed,
  });

  final int pushed;
  final int failed;
}
