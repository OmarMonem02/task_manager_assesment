import '../../domain/entities/project_entity.dart';
import 'sync_status.dart';

class LocalProjectRecord {
  const LocalProjectRecord({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.description,
    required this.status,
    this.syncStatus = SyncStatus.synced,
  });

  final int id;
  final String name;
  final int userId;
  final int createdAt;
  final String description;
  final String status;
  final SyncStatus syncStatus;

  factory LocalProjectRecord.fromJson(Map<dynamic, dynamic> json) {
    return LocalProjectRecord(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      userId: json['userId'] as int,
      createdAt: json['createdAt'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      syncStatus: SyncStatusX.fromName(json['syncStatus'] as String? ?? 'synced'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt,
      'description': description,
      'status': status,
      'syncStatus': syncStatus.name,
    };
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      userId: userId,
      createdAt: createdAt,
      description: description,
      status: status,
    );
  }

  LocalProjectRecord copyWith({
    int? id,
    String? name,
    int? userId,
    int? createdAt,
    String? description,
    String? status,
    SyncStatus? syncStatus,
  }) {
    return LocalProjectRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
