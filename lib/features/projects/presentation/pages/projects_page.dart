import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/project_card.dart';
import '../widgets/empty_projects.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Projects',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF1A1A2E)),
            onPressed: () => context.push(AppRouter.profile),
          ),
        ],
      ),
      body: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsLoading) {
            return _buildSkeletonList();
          }

          if (state is ProjectsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: Colors.red[300]),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProjectsBloc>()
                        .add(GetProjectsRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProjectsEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF6C63FF),
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
              color: const Color(0xFF6C63FF),
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
        },
      ),
      floatingActionButton: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsLoaded || state is ProjectsEmpty || state is ProjectsError) {
            return FloatingActionButton(
              onPressed: () => _showCreateProjectSheet(context),
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => SkeletonCard(),
    );
  }
}

