import 'package:get_it/get_it.dart';
import '../network/dio_factory.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/projects/data/datasources/projects_remote_datasource.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/usecases/add_task_usecase.dart';
import '../../features/projects/domain/usecases/get_project_tasks_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/mark_task_done_usecase.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ─── Dio ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => DioFactory.createAuthDio(), instanceName: 'authDio');
  sl.registerLazySingleton(() => DioFactory.createProjectsDio(), instanceName: 'projectsDio');

  // ─── Auth DataSources ──────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(instanceName: 'authDio')),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // ─── Auth Repository ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ─── Auth Use Cases ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

  // ─── Auth BLoC ─────────────────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );

  // ─── Projects DataSources ──────────────────────────────────────────────
  sl.registerLazySingleton<ProjectsRemoteDataSource>(
    () => ProjectsRemoteDataSourceImpl(sl(instanceName: 'projectsDio')),
  );

  // ─── Projects Repository ───────────────────────────────────────────────
  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(remoteDataSource: sl()),
  );

  // ─── Projects Use Cases ────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => MarkTaskDoneUseCase(sl()));

  // ─── Projects BLoC ─────────────────────────────────────────────────────
  sl.registerFactory(
    () => ProjectsBloc(
      getProjectsUseCase: sl(),
      getProjectTasksUseCase: sl(),
      addTaskUseCase: sl(),
      markTaskDoneUseCase: sl(),
    ),
  );
}