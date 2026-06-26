import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectsRequested extends ProjectsEvent {}

class GetProjectTasksRequested extends ProjectsEvent {
  final int projectId;
  const GetProjectTasksRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class AddTaskRequested extends ProjectsEvent {
  final String title;
  final int projectId;
  const AddTaskRequested({required this.title, required this.projectId});

  @override
  List<Object?> get props => [title, projectId];
}

class MarkTaskDoneRequested extends ProjectsEvent {
  final int taskId;
  const MarkTaskDoneRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}