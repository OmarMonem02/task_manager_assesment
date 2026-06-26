import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/get_project_tasks_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/mark_task_done_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final GetProjectTasksUseCase _getProjectTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final MarkTaskDoneUseCase _markTaskDoneUseCase;

  // Keep current tasks in memory for optimistic updates
  List<TaskEntity> _currentTasks = [];

  ProjectsBloc({
    required GetProjectsUseCase getProjectsUseCase,
    required GetProjectTasksUseCase getProjectTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required MarkTaskDoneUseCase markTaskDoneUseCase,
  })  : _getProjectsUseCase = getProjectsUseCase,
        _getProjectTasksUseCase = getProjectTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _markTaskDoneUseCase = markTaskDoneUseCase,
        super(ProjectsInitial()) {
    on<GetProjectsRequested>(_onGetProjects);
    on<GetProjectTasksRequested>(_onGetProjectTasks);
    on<AddTaskRequested>(_onAddTask);
    on<MarkTaskDoneRequested>(_onMarkTaskDone);
  }

  Future<void> _onGetProjects(
    GetProjectsRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    try {
      final projects = await _getProjectsUseCase();
      emit(ProjectsLoaded(projects));
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to load projects'));
    }
  }

  Future<void> _onGetProjectTasks(
    GetProjectTasksRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(TasksLoading());
    try {
      final tasks = await _getProjectTasksUseCase(event.projectId);
      _currentTasks = tasks;
      emit(TasksLoaded(tasks));
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to load tasks'));
    }
  }

  Future<void> _onAddTask(
    AddTaskRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      final task = await _addTaskUseCase(
        title: event.title,
        projectId: event.projectId,
      );
      // Add locally since jsonplaceholder doesn't persist
      _currentTasks = [task, ..._currentTasks];
      emit(TaskAdded(task: task, updatedTasks: _currentTasks));
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onMarkTaskDone(
    MarkTaskDoneRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      await _markTaskDoneUseCase(event.taskId);
      // Update locally since jsonplaceholder doesn't persist
      _currentTasks = _currentTasks.map((task) {
        if (task.id == event.taskId) {
          return task.copyWith(completed: true, status: TaskStatus.done);
        }
        return task;
      }).toList();
      emit(TaskMarkedDone(_currentTasks));
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to update task'));
    }
  }
}