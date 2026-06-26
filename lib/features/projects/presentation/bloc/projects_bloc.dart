import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/shared_pref_helper.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/delete_project_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_project_tasks_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/mark_task_done_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;
  final GetProjectTasksUseCase _getProjectTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final MarkTaskDoneUseCase _markTaskDoneUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  List<TaskEntity> _currentTasks = [];

  ProjectsBloc({
    required GetProjectsUseCase getProjectsUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required GetProjectTasksUseCase getProjectTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required MarkTaskDoneUseCase markTaskDoneUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getProjectsUseCase = getProjectsUseCase,
        _createProjectUseCase = createProjectUseCase,
        _deleteProjectUseCase = deleteProjectUseCase,
        _getProjectTasksUseCase = getProjectTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _markTaskDoneUseCase = markTaskDoneUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(ProjectsInitial()) {
    on<GetProjectsRequested>(_onGetProjects);
    on<CreateProjectRequested>(_onCreateProject);
    on<DeleteProjectRequested>(_onDeleteProject);
    on<GetProjectTasksRequested>(_onGetProjectTasks);
    on<AddTaskRequested>(_onAddTask);
    on<MarkTaskDoneRequested>(_onMarkTaskDone);
    on<DeleteTaskRequested>(_onDeleteTask);
  }

  Future<int?> _getCurrentUserId() => SharedPrefHelper.getUserId();

  Future<void> _emitProjectsForUser(Emitter<ProjectsState> emit) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(const ProjectsError('User not logged in'));
      return;
    }
    final projects = await _getProjectsUseCase(userId);
    if (projects.isEmpty) {
      emit(const ProjectsEmpty());
    } else {
      emit(ProjectsLoaded(projects));
    }
  }

  Future<void> _onGetProjects(
    GetProjectsRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    try {
      await _emitProjectsForUser(emit);
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to load projects'));
    }
  }

  Future<void> _onCreateProject(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(const ProjectsError('User not logged in'));
        return;
      }
      await _createProjectUseCase(
        userId: userId,
        name: event.name,
        description: event.description,
      );
      await _emitProjectsForUser(emit);
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(ProjectsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      await _deleteProjectUseCase(event.projectId);
      await _emitProjectsForUser(emit);
    } on ServerFailure catch (e) {
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to delete project'));
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
        priority: event.priority,
      );
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

  Future<void> _onDeleteTask(
    DeleteTaskRequested event,
    Emitter<ProjectsState> emit,
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
      emit(ProjectsError(e.message));
    } catch (e) {
      emit(const ProjectsError('Failed to delete task'));
    }
  }
}
