import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/utils/project_status_helper.dart';
import '../bloc/tasks/tasks_bloc.dart';
import '../bloc/tasks/tasks_event.dart';
import '../bloc/tasks/tasks_state.dart';
import '../utils/status_presentation.dart';
import '../utils/task_list_extensions.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/task_card.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TasksBloc>()..add(GetProjectTasksRequested(project.id)),
      child: _ProjectDetailsView(project: project),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView({required this.project});

  final ProjectEntity project;

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheet(
        projectId: project.id,
        onAdd: (title, priority) {
          context.read<TasksBloc>().add(
                AddTaskRequested(
                  title: title,
                  projectId: project.id,
                  priority: priority,
                ),
              );
        },
      ),
    );
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    TaskEntity task,
  ) async {
    final confirmed = await showDeleteConfirmation(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task.title}"?',
    );
    if (confirmed && context.mounted) {
      context.read<TasksBloc>().add(
            DeleteTaskRequested(
              taskId: task.id,
              projectId: project.id,
            ),
          );
    }
  }

  List<TaskEntity> _tasksFromState(TasksState state) {
    if (state is TasksLoaded) return state.tasks;
    if (state is TaskAdded) return state.updatedTasks;
    if (state is TaskMarkedDone) return state.updatedTasks;
    if (state is TaskDeleted) return state.updatedTasks;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.primaryText, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          project.name,
          style: TextStyle(fontSize: 16.sp),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTask(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state is TasksError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return const AppLoadingView();
          }

          final tasks = _tasksFromState(state);
          final projectStatus = ProjectStatusHelper.label(
            ProjectStatusHelper.fromTasks(tasks),
          );
          final statusColor =
              StatusPresentation.colorForProjectStatus(projectStatus);

          if (tasks.isEmpty && state is! TasksLoading) {
            return RefreshIndicator(
              color: scheme.primary,
              onRefresh: () async {
                context
                    .read<TasksBloc>()
                    .add(GetProjectTasksRequested(project.id));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildProjectHeader(context, projectStatus, statusColor),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: const EmptyStateView(
                      icon: Icons.task_outlined,
                      title: 'No tasks yet',
                      subtitle: 'Tap + to add your first task',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: scheme.primary,
            onRefresh: () async {
              context
                  .read<TasksBloc>()
                  .add(GetProjectTasksRequested(project.id));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 100.r),
              children: [
                _buildProjectHeader(context, projectStatus, statusColor),
                AppCard(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.primaryText,
                            ),
                          ),
                          Text(
                            '${tasks.doneCount} / ${tasks.length}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: tasks.progress,
                          backgroundColor: colors.skeletonHighlight,
                          color: scheme.primary,
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                ...tasks.map(
                  (task) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: TaskCard(
                      task: task,
                      onMarkDone: task.completed
                          ? null
                          : () => context
                              .read<TasksBloc>()
                              .add(MarkTaskDoneRequested(task.id)),
                      onDelete: () => _confirmDeleteTask(context, task),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectHeader(
    BuildContext context,
    String projectStatus,
    Color statusColor,
  ) {
    final colors = context.appColors;

    return AppCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.description.isNotEmpty) ...[
            Text(
              project.description,
              style: TextStyle(fontSize: 13.sp, color: colors.secondaryText),
            ),
            SizedBox(height: 10.h),
          ],
          StatusBadge(label: projectStatus, color: statusColor),
        ],
      ),
    );
  }
}
