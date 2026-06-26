import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/shared_pref_helper.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  @override
  Future<ProfileModel?> getCachedProfile() async {
    try {
      final cache = await SharedPrefHelper.getUserProfile();
      if (cache == null) return null;
      return ProfileModel.fromCache(cache);
    } catch (e) {
      throw CacheException('Failed to read cached profile');
    }
  }
}
