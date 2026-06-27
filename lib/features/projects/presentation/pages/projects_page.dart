import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/projects/projects_bloc.dart';
import '../bloc/projects/projects_event.dart';
import '../bloc/projects/projects_state.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/empty_projects.dart';
import '../widgets/project_card.dart';
import '../widgets/skeleton_card.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProjectsBloc>()..add(GetProjectsRequested()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectBottomSheet(
        onAdd: (name, description) {
          context.read<ProjectsBloc>().add(
                CreateProjectRequested(name: name, description: description),
              );
        },
      ),
    );
  }

  Future<bool> _confirmDeleteProject(
    BuildContext context,
    String projectName,
  ) {
    return showDeleteConfirmation(
      context,
      title: 'Delete Project',
      message: 'Are you sure you want to delete "$projectName"?',
    );
  }

  void _deleteProject(BuildContext context, int projectId) {
    context.read<ProjectsBloc>().add(DeleteProjectRequested(projectId));
  }

  void _handleSnackbar(BuildContext context, ProjectsState state) {
    final message = switch (state) {
      ProjectsLoaded(:final snackbarMessage) => snackbarMessage,
      ProjectsEmpty(:final snackbarMessage) => snackbarMessage,
      _ => null,
    };

    if (message == null) return;

    if (message.contains('Successfully') ||
        message.contains('up to date')) {
      AppSnackBar.showSuccess(context, message);
    } else {
      AppSnackBar.showError(context, message);
    }
  }

  bool _isOffline(ProjectsState state) {
    return switch (state) {
      ProjectsLoaded(:final isOffline) => isOffline,
      ProjectsEmpty(:final isOffline) => isOffline,
      _ => false,
    };
  }

  int _pendingSyncCount(ProjectsState state) {
    return switch (state) {
      ProjectsLoaded(:final pendingSyncCount) => pendingSyncCount,
      ProjectsEmpty(:final pendingSyncCount) => pendingSyncCount,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return BlocListener<ProjectsBloc, ProjectsState>(
      listenWhen: (previous, current) =>
          current is ProjectsLoaded || current is ProjectsEmpty,
      listener: _handleSnackbar,
      child: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          final isOffline = _isOffline(state);
          final pendingSyncCount = _pendingSyncCount(state);
          final isSyncing = state is ProjectsSyncing;

          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: AppBar(
              title: const Text('My Projects'),
              actions: [
                IconButton(
                  tooltip: 'Sync projects',
                  onPressed: isSyncing || isOffline
                      ? null
                      : () => context
                          .read<ProjectsBloc>()
                          .add(SyncProjectsRequested()),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      isSyncing
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primaryText,
                              ),
                            )
                          : Icon(Icons.sync, color: colors.primaryText),
                      if (pendingSyncCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: scheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.person_outline, color: colors.primaryText),
                  onPressed: () => context.push(AppRouter.profile),
                ),
              ],
            ),
            body: Column(
              children: [
                if (isOffline)
                  Container(
                    width: double.infinity,
                    color: scheme.surfaceContainerHighest,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Text(
                      pendingSyncCount > 0
                          ? 'Offline mode • $pendingSyncCount pending changes'
                          : 'Offline mode • changes will sync when you reconnect',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
            floatingActionButton: _buildFab(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectsState state) {
    final scheme = context.colorScheme;

    if (state is ProjectsLoading || state is ProjectsSyncing) {
      return state is ProjectsSyncing
          ? const AppLoadingView()
          : _buildSkeletonList();
    }

    if (state is ProjectsError) {
      return AppErrorView(
        message: state.message,
        onRetry: () =>
            context.read<ProjectsBloc>().add(GetProjectsRequested()),
      );
    }

    if (state is ProjectsEmpty) {
      return RefreshIndicator(
        color: scheme.primary,
        onRefresh: () async {
          context.read<ProjectsBloc>().add(GetProjectsRequested());
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: EmptyProjects(
                onCreateProject: () => _showCreateProjectSheet(context),
              ),
            ),
          ],
        ),
      );
    }

    if (state is ProjectsLoaded) {
      return RefreshIndicator(
        color: scheme.primary,
        onRefresh: () async {
          context.read<ProjectsBloc>().add(GetProjectsRequested());
        },
        child: SlidableAutoCloseBehavior(
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.projects.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final project = state.projects[index];
              return ProjectCard(
                project: project,
                onTap: () => context.push(
                  '/projects/${project.id}',
                  extra: project,
                ),
                onConfirmDelete: () => _confirmDeleteProject(
                  context,
                  project.name,
                ),
                onDelete: () => _deleteProject(context, project.id),
              );
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget? _buildFab(BuildContext context, ProjectsState state) {
    if (state is ProjectsLoaded ||
        state is ProjectsEmpty ||
        state is ProjectsError) {
      return FloatingActionButton(
        onPressed: () => _showCreateProjectSheet(context),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
