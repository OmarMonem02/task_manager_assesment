import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectsRequested extends ProjectsEvent {}

class CreateProjectRequested extends ProjectsEvent {
  const CreateProjectRequested({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  @override
  List<Object?> get props => [name, description];
}

class DeleteProjectRequested extends ProjectsEvent {
  const DeleteProjectRequested(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}

class SyncProjectsRequested extends ProjectsEvent {}
