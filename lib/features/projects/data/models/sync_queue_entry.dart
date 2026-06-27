enum SyncEntityType { project, task }

enum SyncOperation { create, update, delete }

class SyncQueueEntry {
  const SyncQueueEntry({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.operation,
    required this.localEntityId,
    required this.payload,
    required this.createdAt,
    this.projectId,
  });

  final String id;
  final int userId;
  final SyncEntityType entityType;
  final SyncOperation operation;
  final int localEntityId;
  final Map<String, dynamic> payload;
  final int createdAt;
  final int? projectId;

  factory SyncQueueEntry.fromJson(Map<dynamic, dynamic> json) {
    return SyncQueueEntry(
      id: json['id'] as String,
      userId: json['userId'] as int,
      entityType: SyncEntityType.values.firstWhere(
        (value) => value.name == json['entityType'],
      ),
      operation: SyncOperation.values.firstWhere(
        (value) => value.name == json['operation'],
      ),
      localEntityId: json['localEntityId'] as int,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: json['createdAt'] as int,
      projectId: json['projectId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'entityType': entityType.name,
      'operation': operation.name,
      'localEntityId': localEntityId,
      'payload': payload,
      'createdAt': createdAt,
      if (projectId != null) 'projectId': projectId,
    };
  }
}
