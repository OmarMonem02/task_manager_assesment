import '../../../../core/network/api_constants.dart';
import '../models/task_model.dart';
import 'dio_projects_client.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskModel>> getProjectTasks(int projectId);
  Future<TaskModel> addTask({
    required String title,
    required int projectId,
    String priority,
  });
  Future<TaskModel> markTaskDone(int taskId);
  Future<void> deleteTask({required int taskId, required int projectId});
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  TasksRemoteDataSourceImpl(DioProjectsClient client) : _client = client;

  final DioProjectsClient _client;

  @override
  Future<List<TaskModel>> getProjectTasks(int projectId) {
    return _client.getList(
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
  }) {
    return _client.post(
      endpoint: ApiConstants.todosEndpoint,
      data: {
        'title': title,
        'projectId': projectId,
        'completed': false,
        'status': 'Pending',
        'priority': priority,
        'description': '',
        'dueDate': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      fromJson: TaskModel.fromJson,
      errorMessage: 'Failed to add task',
    );
  }

  @override
  Future<TaskModel> markTaskDone(int taskId) {
    return _client.patch(
      endpoint: '${ApiConstants.todosEndpoint}/$taskId',
      data: {'completed': true, 'status': 'Done'},
      fromJson: TaskModel.fromJson,
      errorMessage: 'Failed to update task',
    );
  }

  @override
  Future<void> deleteTask({
    required int taskId,
    required int projectId,
  }) {
    return _client.delete(
      endpoint: '${ApiConstants.albumsEndpoint}/$projectId/tasks/$taskId',
      errorMessage: 'Failed to delete task',
    );
  }
}
