import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDelete,
  });

  Color _statusColor() {
    switch (project.status.toLowerCase()) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
                    color: const Color(0xFF6C63FF),
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
                      color: const Color(0xFF1A1A2E),
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
                        color: Colors.grey[600],
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
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            SizedBox(width: 4.w),
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14.r,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
