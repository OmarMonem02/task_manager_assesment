import 'package:equatable/equatable.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';

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
  final List<ProjectEntity> projects;
  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class TasksLoading extends ProjectsState {}

class TasksLoaded extends ProjectsState {
  final List<TaskEntity> tasks;
  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskAdded extends ProjectsState {
  final TaskEntity task;
  final List<TaskEntity> updatedTasks;
  const TaskAdded({required this.task, required this.updatedTasks});

  @override
  List<Object?> get props => [task, updatedTasks];
}

class TaskMarkedDone extends ProjectsState {
  final List<TaskEntity> updatedTasks;
  const TaskMarkedDone(this.updatedTasks);

  @override
  List<Object?> get props => [updatedTasks];
}

class TaskDeleted extends ProjectsState {
  final List<TaskEntity> updatedTasks;
  const TaskDeleted(this.updatedTasks);

  @override
  List<Object?> get props => [updatedTasks];
}

class ProjectsError extends ProjectsState {
  final String message;
  const ProjectsError(this.message);

  @override
  List<Object?> get props => [message];
}