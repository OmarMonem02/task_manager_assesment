import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class GetProjectTasksUseCase {
  GetProjectTasksUseCase(this._repository);

  final TasksRepository _repository;

  Future<List<TaskEntity>> call(int projectId) =>
      _repository.getProjectTasks(projectId);
}
