import '../entities/project_entity.dart';
import '../repositories/projects_repository.dart';

class CreateProjectUseCase {
  final ProjectsRepository _repository;
  CreateProjectUseCase(this._repository);

  Future<ProjectEntity> call({
    required int userId,
    required String name,
    required String description,
    String status = 'active',
  }) {
    if (name.trim().isEmpty) {
      throw Exception('Project name cannot be empty');
    }
    return _repository.createProject(
      userId: userId,
      name: name.trim(),
      description: description.trim(),
      status: status,
    );
  }
}
