import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remoteDataSource;

  ProjectsRepositoryImpl({required ProjectsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProjectEntity>> getProjects() async {
    try {
      return await _remoteDataSource.getProjects();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<TaskEntity>> getProjectTasks(int projectId) async {
    try {
      return await _remoteDataSource.getProjectTasks(projectId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskEntity> addTask({
    required String title,
    required int projectId,
  }) async {
    try {
      return await _remoteDataSource.addTask(
        title: title,
        projectId: projectId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskEntity> markTaskDone(int taskId) async {
    try {
      return await _remoteDataSource.markTaskDone(taskId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}