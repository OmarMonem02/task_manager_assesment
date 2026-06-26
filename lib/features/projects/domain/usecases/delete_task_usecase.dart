import '../repositories/projects_repository.dart';

class DeleteTaskUseCase {
  final ProjectsRepository _repository;
  DeleteTaskUseCase(this._repository);

  Future<void> call({
    required int taskId,
    required int projectId,
  }) =>
      _repository.deleteTask(taskId: taskId, projectId: projectId);
}
