import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onMarkDone;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onMarkDone,
    this.onDelete,
  });

  Color _statusColor() {
    switch (task.status) {
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.pending:
        return Colors.grey;
    }
  }

  String _statusLabel() {
    switch (task.status) {
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
    }
  }

  Color _priorityColor() {
    switch (task.priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                color: task.completed
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                border: Border.all(
                  color: task.completed
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: task.completed
                  ? Icon(Icons.check, size: 14.r, color: Colors.white)
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
                        ? Colors.grey[400]
                        : const Color(0xFF1A1A2E),
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _statusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _priorityColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _priorityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
