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
  const ProjectsEmpty({
    this.isOffline = false,
    this.pendingSyncCount = 0,
    this.snackbarMessage,
  });

  final bool isOffline;
  final int pendingSyncCount;
  final String? snackbarMessage;

  @override
  List<Object?> get props => [isOffline, pendingSyncCount, snackbarMessage];
}

class ProjectsLoaded extends ProjectsState {
  const ProjectsLoaded(
    this.projects, {
    this.isOffline = false,
    this.pendingSyncCount = 0,
    this.snackbarMessage,
  });

  final List<ProjectEntity> projects;
  final bool isOffline;
  final int pendingSyncCount;
  final String? snackbarMessage;

  @override
  List<Object?> get props => [
        projects,
        isOffline,
        pendingSyncCount,
        snackbarMessage,
      ];
}

class ProjectsSyncing extends ProjectsState {}

class ProjectsError extends ProjectsState {
  const ProjectsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
