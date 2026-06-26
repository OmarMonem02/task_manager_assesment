import '../entities/project_entity.dart';
import '../repositories/projects_repository.dart';

class GetProjectsUseCase {
  GetProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<ProjectEntity>> call(int userId) =>
      _repository.getProjects(userId: userId);
}
