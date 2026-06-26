import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/status_presentation.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onMarkDone,
    this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback? onMarkDone;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return AppCard(
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMarkDone,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.completed ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: task.completed ? scheme.primary : colors.divider,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? Icon(Icons.check, size: 14.r, color: scheme.onPrimary)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: task.completed
                        ? colors.iconMuted
                        : colors.primaryText,
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    StatusBadge(
                      label: StatusPresentation.labelForTaskStatus(task.status),
                      color: StatusPresentation.colorForTaskStatus(task.status),
                    ),
                    SizedBox(width: 6.w),
                    StatusBadge(
                      label: task.priority,
                      color: StatusPresentation.colorForPriority(task.priority),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
