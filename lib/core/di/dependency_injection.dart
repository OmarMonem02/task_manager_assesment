import 'package:get_it/get_it.dart';
import '../network/dio_factory.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/projects/data/datasources/projects_remote_datasource.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/usecases/add_task_usecase.dart';
import '../../features/projects/domain/usecases/delete_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_task_usecase.dart';
import '../../features/projects/domain/usecases/get_project_tasks_usecase.dart';
import '../../features/projects/domain/usecases/create_project_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/mark_task_done_usecase.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';
import '../../features/theme/data/datasources/theme_local_datasource.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/usecases/get_theme_mode_usecase.dart';
import '../../features/theme/domain/usecases/set_theme_mode_usecase.dart';
import '../../features/theme/presentation/cubit/theme_cubit.dart';

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
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

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
    () => ProfileLocalDataSourceImpl(),
  );

  // ─── Profile Repository ────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      localDataSource: sl(),
      authRepository: sl(),
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
  sl.registerLazySingleton<ProjectsRemoteDataSource>(
    () => ProjectsRemoteDataSourceImpl(sl(instanceName: 'projectsDio')),
  );

  // ─── Projects Repository ───────────────────────────────────────────────
  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(remoteDataSource: sl()),
  );

  // ─── Projects Use Cases ────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => MarkTaskDoneUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // ─── Projects BLoC ─────────────────────────────────────────────────────
  sl.registerFactory(
    () => ProjectsBloc(
      getProjectsUseCase: sl(),
      createProjectUseCase: sl(),
      deleteProjectUseCase: sl(),
      getProjectTasksUseCase: sl(),
      addTaskUseCase: sl(),
      markTaskDoneUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

  // ─── Theme DataSources ─────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(),
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