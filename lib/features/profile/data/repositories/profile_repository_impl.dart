import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;
  final AuthRepository _authRepository;

  ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    required AuthRepository authRepository,
  })  : _localDataSource = localDataSource,
        _authRepository = authRepository;

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final cached = await _localDataSource.getCachedProfile();
      if (cached != null) return cached;

      final user = await _authRepository.getMe();
      return ProfileModel.fromUserEntity(user);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } on UnauthorizedFailure catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
