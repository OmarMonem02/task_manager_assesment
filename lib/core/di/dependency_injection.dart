import 'package:get_it/get_it.dart';
import '../network/connectivity_service.dart';
import '../network/dio_factory.dart';
import '../network/token_provider.dart';
import '../storage/local_storage.dart';
import '../storage/session_storage.dart';
import '../storage/shared_preferences_local_storage.dart';
import '../storage/theme_storage.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/auth_user_reader.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/repositories/user_reader.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/projects/data/datasources/dio_projects_client.dart';
import '../../features/projects/data/datasources/projects_local_datasource.dart';
import '../../features/projects/data/datasources/projects_remote_datasource.dart';
import '../../features/projects/data/datasources/sync_queue_local_datasource.dart';
import '../../features/projects/data/datasources/tasks_local_datasource.dart';
import '../../features/projects/data/datasources/tasks_remote_datasource.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/data/repositories/sync_repository_impl.dart';
import '../../features/projects/data/repositories/tasks_repository_impl.dart';
import '../../features/projects/data/services/user_projects_storage_cleaner.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/repositories/sync_repository.dart';
import '../../features/projects/domain/repositories/tasks_repository.dart';
import '../../features/projects/domain/usecases/add_task_usecase.dart';
import '../../features/projects/domain/usecases/create_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_task_usecase.dart';
import '../../features/projects/domain/usecases/enrich_projects_with_status_usecase.dart';
import '../../features/projects/domain/usecases/get_project_tasks_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/mark_task_done_usecase.dart';
import '../../features/projects/domain/usecases/sync_projects_usecase.dart';
import '../../features/projects/presentation/bloc/projects/projects_bloc.dart';
import '../../features/projects/presentation/bloc/tasks/tasks_bloc.dart';
import '../../features/theme/data/datasources/theme_local_datasource.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/usecases/get_theme_mode_usecase.dart';
import '../../features/theme/domain/usecases/set_theme_mode_usecase.dart';
import '../../features/theme/presentation/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ─── Storage ───────────────────────────────────────────────────────────
  final localStorage = await SharedPreferencesLocalStorage.create();
  sl.registerLazySingleton<LocalStorage>(() => localStorage);
  sl.registerLazySingleton<SessionStorage>(
    () => SharedPreferencesSessionStorage(sl()),
  );
  sl.registerLazySingleton<ThemeStorage>(
    () => SharedPreferencesThemeStorage(sl()),
  );

  // ─── Network ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityServiceImpl());
  sl.registerLazySingleton<TokenProvider>(
    () => SessionTokenProvider(sl()),
  );
  sl.registerLazySingleton(() => DioFactory(sl()));
  sl.registerLazySingleton(
    () => sl<DioFactory>().createAuthDio(),
    instanceName: 'authDio',
  );
  sl.registerLazySingleton(
    () => sl<DioFactory>().createProjectsDio(),
    instanceName: 'projectsDio',
  );

  // ─── Auth DataSources ──────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(instanceName: 'authDio')),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // ─── Auth Repository ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      userProjectsStorageCleaner: sl(),
    ),
  );

  // ─── Auth Use Cases ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserIdUseCase(sl()));

  // ─── Auth BLoC ─────────────────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );

  // ─── Profile DataSources ───────────────────────────────────────────────
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl()),
  );

  // ─── Profile Repository ────────────────────────────────────────────────
  sl.registerLazySingleton<UserReader>(() => AuthUserReader(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      localDataSource: sl(),
      userReader: sl(),
    ),
  );

  // ─── Profile Use Cases ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // ─── Profile BLoC ──────────────────────────────────────────────────────
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ─── Projects DataSources ──────────────────────────────────────────────
  sl.registerLazySingleton<ProjectsLocalDataSource>(
    () => ProjectsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<TasksLocalDataSource>(
    () => TasksLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SyncQueueLocalDataSource>(
    () => SyncQueueLocalDataSourceImpl(),
  );
  sl.registerLazySingleton(
    () => DioProjectsClient(sl(instanceName: 'projectsDio')),
  );
  sl.registerLazySingleton<ProjectsRemoteDataSource>(
    () => ProjectsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TasksRemoteDataSource>(
    () => TasksRemoteDataSourceImpl(sl()),
  );

  // ─── Projects Repositories ─────────────────────────────────────────────
  sl.registerLazySingleton<UserProjectsStorageCleaner>(
    () => UserProjectsStorageCleaner(
      projectsLocalDataSource: sl(),
      tasksLocalDataSource: sl(),
      syncQueueLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      syncQueueLocalDataSource: sl(),
      connectivityService: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      projectsLocalDataSource: sl(),
      syncQueueLocalDataSource: sl(),
      connectivityService: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      projectsRemoteDataSource: sl(),
      tasksRemoteDataSource: sl(),
      projectsLocalDataSource: sl(),
      tasksLocalDataSource: sl(),
      syncQueueLocalDataSource: sl(),
      connectivityService: sl(),
    ),
  );

  // ─── Projects Use Cases ────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(
    () => EnrichProjectsWithStatusUseCase(sl(), sl()),
  );
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => MarkTaskDoneUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => SyncProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingSyncCountUseCase(sl()));

  // ─── Projects BLoC ─────────────────────────────────────────────────────
  sl.registerFactory(
    () => ProjectsBloc(
      enrichProjectsWithStatusUseCase: sl(),
      createProjectUseCase: sl(),
      deleteProjectUseCase: sl(),
      getCurrentUserIdUseCase: sl(),
      syncProjectsUseCase: sl(),
      getPendingSyncCountUseCase: sl(),
      connectivityService: sl(),
    ),
  );

  // ─── Tasks BLoC ────────────────────────────────────────────────────────
  sl.registerFactory(
    () => TasksBloc(
      getProjectTasksUseCase: sl(),
      addTaskUseCase: sl(),
      markTaskDoneUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

  // ─── Theme DataSources ─────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(sl()),
  );

  // ─── Theme Repository ──────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(localDataSource: sl()),
  );

  // ─── Theme Use Cases ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => SetThemeModeUseCase(sl()));

  // ─── Theme Cubit ───────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => ThemeCubit(
      getThemeModeUseCase: sl(),
      setThemeModeUseCase: sl(),
    ),
  );
}
