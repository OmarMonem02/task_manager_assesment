import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/project_entity.dart';
import '../utils/status_presentation.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onConfirmDelete,
    this.onDelete,
  });

  final ProjectEntity project;
  final VoidCallback onTap;
  final Future<bool> Function()? onConfirmDelete;
  final VoidCallback? onDelete;

  Widget _buildCardContent(BuildContext context) {
    final scheme = context.colorScheme;
    final statusColor = StatusPresentation.colorForProjectStatus(project.status);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(16.r),
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
                    color: context.appColors.primaryText,
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
                      color: context.appColors.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                StatusBadge(label: project.status, color: statusColor),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: context.appColors.iconMuted,
            ),
          ),
        ],
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
