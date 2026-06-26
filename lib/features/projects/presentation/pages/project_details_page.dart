import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/utils/project_status_helper.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/delete_confirmation_dialog.dart';

class ProjectDetailsPage extends StatelessWidget {
  final ProjectEntity project;
  const ProjectDetailsPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProjectsBloc>()..add(GetProjectTasksRequested(project.id)),
      child: _ProjectDetailsView(project: project),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  final ProjectEntity project;
  const _ProjectDetailsView({required this.project});

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheet(
        projectId: project.id,
        onAdd: (title, priority) {
          context.read<ProjectsBloc>().add(
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
      context.read<ProjectsBloc>().add(
            DeleteTaskRequested(
              taskId: task.id,
              projectId: project.id,
            ),
          );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTask(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ProjectsBloc, ProjectsState>(
        listener: (context, state) {
          if (state is ProjectsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          List<TaskEntity> tasks = [];

          if (state is TasksLoaded) tasks = state.tasks;
          if (state is TaskAdded) tasks = state.updatedTasks;
          if (state is TaskMarkedDone) tasks = state.updatedTasks;
          if (state is TaskDeleted) tasks = state.updatedTasks;

          final projectStatus = ProjectStatusHelper.label(
            ProjectStatusHelper.fromTasks(tasks),
          );

          if (tasks.isEmpty && state is! TasksLoading) {
            return RefreshIndicator(
              color: const Color(0xFF6C63FF),
              onRefresh: () async {
                context
                    .read<ProjectsBloc>()
                    .add(GetProjectTasksRequested(project.id));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildProjectHeader(projectStatus),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_outlined,
                              size: 64.r, color: Colors.grey[300]),
                          SizedBox(height: 16.h),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap + to add your first task',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final done = tasks.where((t) => t.status == TaskStatus.done).length;
          final total = tasks.length;

          return RefreshIndicator(
            color: const Color(0xFF6C63FF),
            onRefresh: () async {
              context
                  .read<ProjectsBloc>()
                  .add(GetProjectTasksRequested(project.id));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 100.r),
              children: [
                _buildProjectHeader(projectStatus),
                Container(
                  margin: EdgeInsets.only(bottom: 16.r),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
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
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '$done / $total',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : done / total,
                          backgroundColor: Colors.grey[100],
                          color: const Color(0xFF6C63FF),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                ...tasks.map(
                  (task) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: TaskCard(
                      task: task,
                      onMarkDone: task.completed
                          ? null
                          : () => context
                              .read<ProjectsBloc>()
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

  Widget _buildProjectHeader(String projectStatus) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 16.r, 0, 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.description.isNotEmpty) ...[
            Text(
              project.description,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 10.h),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor(projectStatus).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              projectStatus,
              style: TextStyle(
                fontSize: 11.sp,
                color: _statusColor(projectStatus),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
