import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectsRequested extends ProjectsEvent {}

class CreateProjectRequested extends ProjectsEvent {
  final String name;
  final String description;
  const CreateProjectRequested({
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class DeleteProjectRequested extends ProjectsEvent {
  final int projectId;
  const DeleteProjectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class GetProjectTasksRequested extends ProjectsEvent {
  final int projectId;
  const GetProjectTasksRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class AddTaskRequested extends ProjectsEvent {
  final String title;
  final int projectId;
  final String priority;
  const AddTaskRequested({
    required this.title,
    required this.projectId,
    this.priority = 'Medium',
  });

  @override
  List<Object?> get props => [title, projectId, priority];
}

class DeleteTaskRequested extends ProjectsEvent {
  final int taskId;
  final int projectId;
  const DeleteTaskRequested({
    required this.taskId,
    required this.projectId,
  });

  @override
  List<Object?> get props => [taskId, projectId];
}

class MarkTaskDoneRequested extends ProjectsEvent {
  final int taskId;
  const MarkTaskDoneRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}