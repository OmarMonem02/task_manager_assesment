import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  const TasksLoaded(this.tasks);

  final List<TaskEntity> tasks;

  @override
  List<Object?> get props => [tasks];
}

class TaskAdded extends TasksState {
  const TaskAdded({required this.task, required this.updatedTasks});

  final TaskEntity task;
  final List<TaskEntity> updatedTasks;

  @override
  List<Object?> get props => [task, updatedTasks];
}

class TaskMarkedDone extends TasksState {
  const TaskMarkedDone(this.updatedTasks);

  final List<TaskEntity> updatedTasks;

  @override
  List<Object?> get props => [updatedTasks];
}

class TaskDeleted extends TasksState {
  const TaskDeleted(this.updatedTasks);

  final List<TaskEntity> updatedTasks;

  @override
  List<Object?> get props => [updatedTasks];
}

class TasksError extends TasksState {
  const TasksError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
