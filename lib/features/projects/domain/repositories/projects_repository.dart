import '../entities/project_entity.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> getProjects({required int userId});
  Future<ProjectEntity> createProject({
    required int userId,
    required String name,
    required String description,
    String status,
  });
  Future<void> deleteProject(int projectId);
}
