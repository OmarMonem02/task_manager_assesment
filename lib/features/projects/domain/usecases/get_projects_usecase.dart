import '../entities/project_entity.dart';
import '../repositories/projects_repository.dart';
import '../utils/project_status_helper.dart';

class GetProjectsUseCase {
  final ProjectsRepository _repository;
  GetProjectsUseCase(this._repository);

  Future<List<ProjectEntity>> call(int userId) async {
    final projects = await _repository.getProjects(userId: userId);
    final enriched = await Future.wait(
      projects.map((project) async {
        final tasks = await _repository.getProjectTasks(project.id);
        final displayStatus = ProjectStatusHelper.label(
          ProjectStatusHelper.fromTasks(tasks),
        );
        return project.copyWith(status: displayStatus);
      }),
    );
    return enriched;
  }
}