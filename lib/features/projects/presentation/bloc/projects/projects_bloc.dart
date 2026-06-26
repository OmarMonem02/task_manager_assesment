import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../domain/usecases/create_project_usecase.dart';
import '../../../domain/usecases/delete_project_usecase.dart';
import '../../../domain/usecases/enrich_projects_with_status_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({
    required EnrichProjectsWithStatusUseCase enrichProjectsWithStatusUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required GetCurrentUserIdUseCase getCurrentUserIdUseCase,
  })  : _enrichProjectsWithStatusUseCase = enrichProjectsWithStatusUseCase,
        _createProjectUseCase = createProjectUseCase,
        _deleteProjectUseCase = deleteProjectUseCase,
        _getCurrentUserIdUseCase = getCurrentUserIdUseCase,
        super(ProjectsInitial()) {
    on<GetProjectsRequested>(_onGetProjects);
    on<CreateProjectRequested>(_onCreateProject);
    on<DeleteProjectRequested>(_onDeleteProject);
  }

  final EnrichProjectsWithStatusUseCase _enrichProjectsWithStatusUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;
  final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;

  Future<void> _emitProjectsForUser(Emitter<ProjectsState> emit) async {
    final userId = await _getCurrentUserIdUseCase();
    if (userId == null) {
      emit(const ProjectsError('User not logged in'));
      return;
    }
    final projects = await _enrichProjectsWithStatusUseCase(userId);
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
    } catch (_) {
      emit(const ProjectsError('Failed to load projects'));
    }
  }

  Future<void> _onCreateProject(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      final userId = await _getCurrentUserIdUseCase();
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
    } catch (_) {
      emit(const ProjectsError('Failed to delete project'));
    }
  }
}
