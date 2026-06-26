import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/utils/project_status_helper.dart';

class StatusPresentation {
  StatusPresentation._();

  static Color colorForProjectStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.statusCompleted;
      case 'in progress':
        return AppColors.statusInProgress;
      default:
        return AppColors.statusPending;
    }
  }

  static Color colorForDisplayStatus(ProjectDisplayStatus status) {
    switch (status) {
      case ProjectDisplayStatus.completed:
        return AppColors.statusCompleted;
      case ProjectDisplayStatus.inProgress:
        return AppColors.statusInProgress;
      case ProjectDisplayStatus.pending:
        return AppColors.statusPending;
    }
  }

  static Color colorForTaskStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return AppColors.statusCompleted;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.pending:
        return AppColors.statusPending;
    }
  }

  static String labelForTaskStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
    }
  }

  static Color colorForPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }
}
