import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

abstract class ProjectsRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<List<TaskModel>> getProjectTasks(int projectId);
  Future<TaskModel> addTask({required String title, required int projectId});
  Future<TaskModel> markTaskDone(int taskId);
}

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final Dio _dio;
  ProjectsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _dio.get(ApiConstants.albumsEndpoint);
      final List data = response.data;
      return data.map((e) => ProjectModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch projects');
    }
  }

  @override
  Future<List<TaskModel>> getProjectTasks(int projectId) async {
    try {
      final response = await _dio.get(
        ApiConstants.todosEndpoint,
        queryParameters: {'albumId': projectId},
      );
      final List data = response.data;
      return data.map((e) => TaskModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch tasks');
    }
  }

  @override
  Future<TaskModel> addTask({
    required String title,
    required int projectId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.todosEndpoint,
        data: {
          'title': title,
          'albumId': projectId,
          'completed': false,
          'userId': 1,
        },
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to add task');
    }
  }

  @override
  Future<TaskModel> markTaskDone(int taskId) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.todosEndpoint}/$taskId',
        data: {'completed': true},
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update task');
    }
  }
}