import 'package:equatable/equatable.dart';
import '../../../domain/entities/project_entity.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsEmpty extends ProjectsState {
  const ProjectsEmpty();
}

class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded(this.projects);

  final List<ProjectEntity> projects;

  @override
  List<Object?> get props => [projects];
}

class ProjectsError extends ProjectsState {
  const ProjectsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
