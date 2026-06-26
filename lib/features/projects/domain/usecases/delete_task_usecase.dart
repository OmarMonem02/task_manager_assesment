import '../repositories/tasks_repository.dart';

class DeleteTaskUseCase {
  DeleteTaskUseCase(this._repository);

  final TasksRepository _repository;

  Future<void> call({
    required int taskId,
    required int projectId,
  }) =>
      _repository.deleteTask(taskId: taskId, projectId: projectId);
}
