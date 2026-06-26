import '../../../../core/network/api_constants.dart';
import '../models/project_model.dart';
import 'dio_projects_client.dart';

abstract class ProjectsRemoteDataSource {
  Future<List<ProjectModel>> getProjects({required int userId});
  Future<ProjectModel> createProject({
    required int userId,
    required String name,
    required String description,
    required String status,
  });
  Future<void> deleteProject(int projectId);
}

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  ProjectsRemoteDataSourceImpl(DioProjectsClient client) : _client = client;

  final DioProjectsClient _client;

  @override
  Future<List<ProjectModel>> getProjects({required int userId}) {
    return _client.getList(
      endpoint: ApiConstants.albumsEndpoint,
      queryParameters: {'userId': userId},
      fromJson: ProjectModel.fromJson,
      errorMessage: 'Failed to fetch projects',
    );
  }

  @override
  Future<ProjectModel> createProject({
    required int userId,
    required String name,
    required String description,
    required String status,
  }) {
    return _client.post(
      endpoint: ApiConstants.albumsEndpoint,
      data: {
        'name': name,
        'description': description,
        'status': status,
        'userId': userId,
        'createdAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      fromJson: ProjectModel.fromJson,
      errorMessage: 'Failed to create project',
    );
  }

  @override
  Future<void> deleteProject(int projectId) {
    return _client.delete(
      endpoint: '${ApiConstants.albumsEndpoint}/$projectId',
      errorMessage: 'Failed to delete project',
    );
  }
}
