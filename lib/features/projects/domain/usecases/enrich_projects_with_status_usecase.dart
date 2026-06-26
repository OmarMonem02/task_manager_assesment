import '../entities/project_entity.dart';
import '../repositories/projects_repository.dart';
import '../repositories/tasks_repository.dart';
import '../utils/project_status_helper.dart';

class EnrichProjectsWithStatusUseCase {
  EnrichProjectsWithStatusUseCase(
    this._projectsRepository,
    this._tasksRepository,
  );

  final ProjectsRepository _projectsRepository;
  final TasksRepository _tasksRepository;

  Future<List<ProjectEntity>> call(int userId) async {
    final projects = await _projectsRepository.getProjects(userId: userId);
    final enriched = await Future.wait(
      projects.map((project) async {
        final tasks = await _tasksRepository.getProjectTasks(project.id);
        final displayStatus = ProjectStatusHelper.label(
          ProjectStatusHelper.fromTasks(tasks),
        );
        return project.copyWith(status: displayStatus);
      }),
    );
    return enriched;
  }
}
