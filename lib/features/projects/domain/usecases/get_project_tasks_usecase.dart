import '../entities/task_entity.dart';
import '../repositories/projects_repository.dart';

class GetProjectTasksUseCase {
  final ProjectsRepository _repository;
  GetProjectTasksUseCase(this._repository);

  Future<List<TaskEntity>> call(int projectId) =>
      _repository.getProjectTasks(projectId);
}