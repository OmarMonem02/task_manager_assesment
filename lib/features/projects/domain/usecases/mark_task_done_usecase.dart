import '../entities/task_entity.dart';
import '../repositories/projects_repository.dart';

class MarkTaskDoneUseCase {
  final ProjectsRepository _repository;
  MarkTaskDoneUseCase(this._repository);

  Future<TaskEntity> call(int taskId) => _repository.markTaskDone(taskId);
}