import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_view.dart';

class EmptyProjects extends StatelessWidget {
  const EmptyProjects({super.key, this.onCreateProject});

  final VoidCallback? onCreateProject;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.folder_open_outlined,
      title: 'No Projects Yet',
      subtitle: 'Create your first project to get started',
      actionLabel: 'Create Project',
      actionIcon: Icons.add,
      onAction: onCreateProject,
    );
  }
}
