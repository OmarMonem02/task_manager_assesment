import '../repositories/projects_repository.dart';

class DeleteProjectUseCase {
  final ProjectsRepository _repository;
  DeleteProjectUseCase(this._repository);

  Future<void> call(int projectId) => _repository.deleteProject(projectId);
}
