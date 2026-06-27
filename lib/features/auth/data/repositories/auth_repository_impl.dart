import '../../../../core/utils/safe_call.dart';
import '../../../projects/data/services/user_projects_storage_cleaner.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required UserProjectsStorageCleaner userProjectsStorageCleaner,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _userProjectsStorageCleaner = userProjectsStorageCleaner;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final UserProjectsStorageCleaner _userProjectsStorageCleaner;

  Future<UserEntity> _persistAuthSession(UserModel user) async {
    await _localDataSource.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      userId: user.id,
    );
    await _localDataSource.saveUserProfile(
      username: user.username,
      email: user.email,
    );
    return user.toEntity();
  }

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) {
    return safeCall(() async {
      final user = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      return _persistAuthSession(user);
    });
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) {
    return safeCall(() async {
      final user = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      return _persistAuthSession(user);
    });
  }

  @override
  Future<UserEntity> getMe() {
    return safeCall(() async {
      final user = await _remoteDataSource.getMe();
      return user.toEntity();
    });
  }

  @override
  Future<void> logout() async {
    final userId = await _localDataSource.getUserId();
    if (userId != null) {
      await _userProjectsStorageCleaner.clearUserData(userId);
    }
    await _localDataSource.clearTokens();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.isLoggedIn();
  }

  @override
  Future<int?> getCurrentUserId() async {
    return _localDataSource.getUserId();
  }
}
