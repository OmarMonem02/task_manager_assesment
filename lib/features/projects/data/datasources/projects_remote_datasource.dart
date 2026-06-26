import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

abstract class ProjectsRemoteDataSource {
  Future<List<ProjectModel>> getProjects({required int userId});
  Future<ProjectModel> createProject({
    required int userId,
    required String name,
    required String description,
    required String status,
  });
  Future<void> deleteProject(int projectId);
  Future<List<TaskModel>> getProjectTasks(int projectId);
  Future<TaskModel> addTask({
    required String title,
    required int projectId,
    String priority,
  });
  Future<TaskModel> markTaskDone(int taskId);
  Future<void> deleteTask({required int taskId, required int projectId});
}

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final Dio _dio;
  ProjectsRemoteDataSourceImpl(this._dio);

  Future<List<T>> _getList<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
    String errorMessage = 'Failed to fetch data',
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 404) return [];
      final data = response.data;
      if (data is! List) return [];
      return data
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? errorMessage);
    } catch (e) {
      throw ServerException(errorMessage);
    }
  }

  @override
  Future<List<ProjectModel>> getProjects({required int userId}) async {
    return _getList(
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
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.albumsEndpoint,
        data: {
          'name': name,
          'description': description,
          'status': status,
          'userId': userId,
          'createdAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      );
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to create project');
    }
  }

  @override
  Future<void> deleteProject(int projectId) async {
    try {
      final response =
          await _dio.delete('${ApiConstants.albumsEndpoint}/$projectId');
      if (response.statusCode == 404) return;
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw ServerException('Failed to delete project');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      throw ServerException(e.message ?? 'Failed to delete project');
    }
  }

  @override
  Future<List<TaskModel>> getProjectTasks(int projectId) async {
    return _getList(
      endpoint: ApiConstants.todosEndpoint,
      queryParameters: {'projectId': projectId},
      fromJson: TaskModel.fromJson,
      errorMessage: 'Failed to fetch tasks',
    );
  }

  @override
  Future<TaskModel> addTask({
    required String title,
    required int projectId,
    String priority = 'Medium',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.todosEndpoint,
        data: {
          'title': title,
          'projectId': projectId,
          'completed': false,
          'status': 'Pending',
          'priority': priority,
          'description': '',
          'dueDate': DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
        data: {'completed': true, 'status': 'Done'},
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update task');
    }
  }

  @override
  Future<void> deleteTask({
    required int taskId,
    required int projectId,
  }) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.albumsEndpoint}/$projectId/tasks/$taskId',
      );
      if (response.statusCode == 404) return;
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw ServerException('Failed to delete task');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      throw ServerException(e.message ?? 'Failed to delete task');
    }
  }
}