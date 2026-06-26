import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final Future<bool> Function()? onConfirmDelete;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onConfirmDelete,
    this.onDelete,
  });

  Color _statusColor() {
    switch (project.status.toLowerCase()) {
      case 'completed':
        return AppColors.statusCompleted;
      case 'in progress':
        return AppColors.statusInProgress;
      default:
        return AppColors.statusPending;
    }
  }

  Widget _buildCardContent(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    project.name.isNotEmpty
                        ? project.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        project.status,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _statusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.r,
                  color: colors.iconMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onConfirmDelete == null || onDelete == null) {
      return _buildCardContent(context);
    }

    final scheme = context.colorScheme;

    return Slidable(
      key: ValueKey(project.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        dismissible: DismissiblePane(
          confirmDismiss: onConfirmDelete,
          onDismissed: onDelete!,
        ),
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (await onConfirmDelete!()) {
                onDelete!();
              }
            },
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(12.r),
            ),
          ),
        ],
      ),
      child: _buildCardContent(context),
    );
  }
}
