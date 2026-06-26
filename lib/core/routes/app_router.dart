import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/domain/entities/project_entity.dart';
import '../storage/shared_pref_helper.dart';

class AppRouter {
  static const String login = '/login';
  static const String projects = '/projects';
  static const String projectDetails = '/projects/:id';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) async {
      final isLoggedIn = await SharedPrefHelper.getAccessToken() != null &&
          (await SharedPrefHelper.getAccessToken())!.isNotEmpty;
      final isOnLogin = state.matchedLocation == login;

      if (!isLoggedIn && !isOnLogin) return login;
      if (isLoggedIn && isOnLogin) return projects;
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: projects,
        builder: (context, state) => const ProjectsPage(),
      ),
      GoRoute(
        path: projectDetails,
        builder: (context, state) {
          final project = state.extra as ProjectEntity;
          return ProjectDetailsPage(project: project);
        },
      ),
    ],
  );
}