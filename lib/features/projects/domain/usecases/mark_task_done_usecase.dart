import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class MarkTaskDoneUseCase {
  MarkTaskDoneUseCase(this._repository);

  final TasksRepository _repository;

  Future<TaskEntity> call(int taskId) => _repository.markTaskDone(taskId);
}
