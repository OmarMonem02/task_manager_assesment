import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyProjects extends StatelessWidget {
  final VoidCallback? onCreateProject;

  const EmptyProjects({super.key, this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 80.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No Projects Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first project to get started',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
          ),
          if (onCreateProject != null) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onCreateProject,
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}