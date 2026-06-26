import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/add_task_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/get_project_tasks_usecase.dart';
import '../../../domain/usecases/mark_task_done_usecase.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({
    required GetProjectTasksUseCase getProjectTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required MarkTaskDoneUseCase markTaskDoneUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getProjectTasksUseCase = getProjectTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _markTaskDoneUseCase = markTaskDoneUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(TasksInitial()) {
    on<GetProjectTasksRequested>(_onGetProjectTasks);
    on<AddTaskRequested>(_onAddTask);
    on<MarkTaskDoneRequested>(_onMarkTaskDone);
    on<DeleteTaskRequested>(_onDeleteTask);
  }

  final GetProjectTasksUseCase _getProjectTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final MarkTaskDoneUseCase _markTaskDoneUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  List<TaskEntity> _currentTasks = [];

  Future<void> _onGetProjectTasks(
    GetProjectTasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    try {
      final tasks = await _getProjectTasksUseCase(event.projectId);
      _currentTasks = tasks;
      emit(TasksLoaded(tasks));
    } on ServerFailure catch (e) {
      emit(TasksError(e.message));
    } catch (_) {
      emit(const TasksError('Failed to load tasks'));
    }
  }

  Future<void> _onAddTask(
    AddTaskRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final task = await _addTaskUseCase(
        title: event.title,
        projectId: event.projectId,
        priority: event.priority,
      );
      _currentTasks = [task, ..._currentTasks];
      emit(TaskAdded(task: task, updatedTasks: _currentTasks));
    } on ServerFailure catch (e) {
      emit(TasksError(e.message));
    } catch (e) {
      emit(TasksError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMarkTaskDone(
    MarkTaskDoneRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _markTaskDoneUseCase(event.taskId);
      _currentTasks = _currentTasks.map((task) {
        if (task.id == event.taskId) {
          return task.copyWith(completed: true, status: TaskStatus.done);
        }
        return task;
      }).toList();
      emit(TaskMarkedDone(_currentTasks));
    } on ServerFailure catch (e) {
      emit(TasksError(e.message));
    } catch (_) {
      emit(const TasksError('Failed to update task'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _deleteTaskUseCase(
        taskId: event.taskId,
        projectId: event.projectId,
      );
      _currentTasks =
          _currentTasks.where((task) => task.id != event.taskId).toList();
      emit(TaskDeleted(_currentTasks));
    } on ServerFailure catch (e) {
      emit(TasksError(e.message));
    } catch (_) {
      emit(const TasksError('Failed to delete task'));
    }
  }
}
