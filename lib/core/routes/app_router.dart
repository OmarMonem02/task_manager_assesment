import 'package:go_router/go_router.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/projects/domain/entities/project_entity.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../di/dependency_injection.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String register = '/register';
  static const String projects = '/projects';
  static const String profile = '/profile';
  static const String projectDetails = '/projects/:id';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) async {
      final isLoggedIn = await sl<CheckAuthUseCase>()();
      final isAuthRoute =
          state.matchedLocation == login || state.matchedLocation == register;

      if (!isLoggedIn && !isAuthRoute) return login;
      if (isLoggedIn && isAuthRoute) return projects;
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: projects,
        builder: (context, state) => const ProjectsPage(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
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
