import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/connectivity_service.dart';
import '../../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../domain/usecases/create_project_usecase.dart';
import '../../../domain/usecases/delete_project_usecase.dart';
import '../../../domain/usecases/enrich_projects_with_status_usecase.dart';
import '../../../domain/usecases/sync_projects_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({
    required EnrichProjectsWithStatusUseCase enrichProjectsWithStatusUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
    required GetCurrentUserIdUseCase getCurrentUserIdUseCase,
    required SyncProjectsUseCase syncProjectsUseCase,
    required GetPendingSyncCountUseCase getPendingSyncCountUseCase,
    required ConnectivityService connectivityService,
  })  : _enrichProjectsWithStatusUseCase = enrichProjectsWithStatusUseCase,
        _createProjectUseCase = createProjectUseCase,
        _deleteProjectUseCase = deleteProjectUseCase,
        _getCurrentUserIdUseCase = getCurrentUserIdUseCase,
        _syncProjectsUseCase = syncProjectsUseCase,
        _getPendingSyncCountUseCase = getPendingSyncCountUseCase,
        _connectivityService = connectivityService,
        super(ProjectsInitial()) {
    on<GetProjectsRequested>(_onGetProjects);
    on<CreateProjectRequested>(_onCreateProject);
    on<DeleteProjectRequested>(_onDeleteProject);
    on<SyncProjectsRequested>(_onSyncProjects);
  }

  final EnrichProjectsWithStatusUseCase _enrichProjectsWithStatusUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;
  final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  final SyncProjectsUseCase _syncProjectsUseCase;
  final GetPendingSyncCountUseCase _getPendingSyncCountUseCase;
  final ConnectivityService _connectivityService;

  Future<({bool isOffline, int pendingSyncCount})> _loadMeta(int userId) async {
    final isOffline = !await _connectivityService.isOnline;
    final pendingSyncCount = await _getPendingSyncCountUseCase(userId);
    return (isOffline: isOffline, pendingSyncCount: pendingSyncCount);
  }

  Future<void> _emitProjectsForUser(
    Emitter<ProjectsState> emit, {
    String? snackbarMessage,
  }) async {
    final userId = await _getCurrentUserIdUseCase();
    if (userId == null) {
      emit(const ProjectsError('User not logged in'));
      return;
    }

    final meta = await _loadMeta(userId);
    final projects = await _enrichProjectsWithStatusUseCase(userId);

    if (projects.isEmpty) {
      emit(ProjectsEmpty(
        isOffline: meta.isOffline,
        pendingSyncCount: meta.pendingSyncCount,
        snackbarMessage: snackbarMessage,
      ));
    } else {
      emit(ProjectsLoaded(
        projects,
        isOffline: meta.isOffline,
        pendingSyncCount: meta.pendingSyncCount,
        snackbarMessage: snackbarMessage,
      ));
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
      final userId = await _getCurrentUserIdUseCase();
      if (userId != null) {
        try {
          final meta = await _loadMeta(userId);
          final projects = await _enrichProjectsWithStatusUseCase(userId);
          if (projects.isNotEmpty) {
            emit(ProjectsLoaded(
              projects,
              isOffline: true,
              pendingSyncCount: meta.pendingSyncCount,
            ));
            return;
          }
        } catch (_) {}
      }
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

  Future<void> _onSyncProjects(
    SyncProjectsRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    final userId = await _getCurrentUserIdUseCase();
    if (userId == null) {
      emit(const ProjectsError('User not logged in'));
      return;
    }

    if (!await _connectivityService.isOnline) {
      await _emitProjectsForUser(
        emit,
        snackbarMessage: 'You are offline. Connect to the internet to sync.',
      );
      return;
    }

    emit(ProjectsSyncing());
    try {
      final result = await _syncProjectsUseCase(userId);
      final message = result.failed > 0
          ? 'Synced ${result.pushed} changes. Some items failed to sync.'
          : result.pushed > 0
              ? 'Successfully synced ${result.pushed} changes.'
              : 'Everything is already up to date.';
      await _emitProjectsForUser(
        emit,
        snackbarMessage: message,
      );
    } on NetworkFailure catch (e) {
      await _emitProjectsForUser(emit, snackbarMessage: e.message);
    } on ServerFailure catch (e) {
      await _emitProjectsForUser(emit, snackbarMessage: e.message);
    } catch (_) {
      await _emitProjectsForUser(
        emit,
        snackbarMessage: 'Failed to sync projects',
      );
    }
  }
}
