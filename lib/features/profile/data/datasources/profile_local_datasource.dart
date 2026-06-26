import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/session_storage.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl(this._sessionStorage);

  final SessionStorage _sessionStorage;

  @override
  Future<ProfileModel?> getCachedProfile() async {
    try {
      final cache = await _sessionStorage.getUserProfile();
      if (cache == null) return null;
      return ProfileModel.fromCache(cache);
    } catch (e) {
      throw CacheException('Failed to read cached profile');
    }
  }
}
