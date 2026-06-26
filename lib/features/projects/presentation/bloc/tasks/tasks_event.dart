import 'package:equatable/equatable.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class GetProjectTasksRequested extends TasksEvent {
  const GetProjectTasksRequested(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}

class AddTaskRequested extends TasksEvent {
  const AddTaskRequested({
    required this.title,
    required this.projectId,
    this.priority = 'Medium',
  });

  final String title;
  final int projectId;
  final String priority;

  @override
  List<Object?> get props => [title, projectId, priority];
}

class DeleteTaskRequested extends TasksEvent {
  const DeleteTaskRequested({
    required this.taskId,
    required this.projectId,
  });

  final int taskId;
  final int projectId;

  @override
  List<Object?> get props => [taskId, projectId];
}

class MarkTaskDoneRequested extends TasksEvent {
  const MarkTaskDoneRequested(this.taskId);

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}
