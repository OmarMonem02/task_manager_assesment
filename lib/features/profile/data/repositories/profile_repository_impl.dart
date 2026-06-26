import '../../../../core/utils/safe_call.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/user_reader.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    required UserReader userReader,
  })  : _localDataSource = localDataSource,
        _userReader = userReader;

  final ProfileLocalDataSource _localDataSource;
  final UserReader _userReader;

  @override
  Future<ProfileEntity> getProfile() {
    return safeCall(() async {
      final cached = await _localDataSource.getCachedProfile();
      if (cached != null) return cached.toEntity();

      final user = await _userReader.getMe();
      return ProfileModel.fromUserEntity(user).toEntity();
    });
  }
}
