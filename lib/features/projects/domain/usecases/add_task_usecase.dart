import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class AddTaskUseCase {
  AddTaskUseCase(this._repository);

  final TasksRepository _repository;

  Future<TaskEntity> call({
    required String title,
    required int projectId,
    String priority = 'Medium',
  }) {
    if (title.trim().isEmpty) {
      throw Exception('Task title cannot be empty');
    }
    return _repository.addTask(
      title: title.trim(),
      projectId: projectId,
      priority: priority,
    );
  }
}
