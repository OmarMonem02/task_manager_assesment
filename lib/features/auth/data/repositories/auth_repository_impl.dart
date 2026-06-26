import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      await _localDataSource.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        userId: user.id,
      );
      await _localDataSource.saveUserProfile(
        username: user.username,
        email: user.email,
      );
      return user;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      await _localDataSource.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        userId: user.id,
      );
      await _localDataSource.saveUserProfile(
        username: user.username,
        email: user.email,
      );
      return user;
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      return await _remoteDataSource.getMe();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearTokens();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.isLoggedIn();
  }
}