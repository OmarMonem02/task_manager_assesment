import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onMarkDone;

  const TaskCard({super.key, required this.task, this.onMarkDone});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
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

          // Title
          Expanded(
            child: Text(
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
          ),
          SizedBox(width: 8.w),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.1),
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
        ],
      ),
    );
  }
}