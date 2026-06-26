import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({required ProjectsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProjectsRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProjectEntity>> getProjects({required int userId}) {
    return safeCall(() async {
      final models = await _remoteDataSource.getProjects(userId: userId);
      return models.map((m) => m.toEntity()).toList();
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
      final model = await _remoteDataSource.createProject(
        userId: userId,
        name: name,
        description: description,
        status: status,
      );
      return model.toEntity();
    });
  }

  @override
  Future<void> deleteProject(int projectId) {
    return safeCall(() => _remoteDataSource.deleteProject(projectId));
  }
}
