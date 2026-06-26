import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/shared_pref_helper.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  });
  Future<void> saveUserProfile({
    required String username,
    required String email,
  });
  Future<Map<String, String>?> getUserProfile();
  Future<String?> getAccessToken();
  Future<bool> isLoggedIn();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    try {
      await SharedPrefHelper.saveAccessToken(accessToken);
      await SharedPrefHelper.saveRefreshToken(refreshToken);
      await SharedPrefHelper.saveUserId(userId);
    } catch (e) {
      throw CacheException('Failed to save tokens');
    }
  }

  @override
  Future<void> saveUserProfile({
    required String username,
    required String email,
  }) async {
    try {
      await SharedPrefHelper.saveUserProfile(
        username: username,
        email: email,
      );
    } catch (e) {
      throw CacheException('Failed to save user profile');
    }
  }

  @override
  Future<Map<String, String>?> getUserProfile() async {
    return SharedPrefHelper.getUserProfile();
  }

  @override
  Future<String?> getAccessToken() async {
    return SharedPrefHelper.getAccessToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await SharedPrefHelper.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearTokens() async {
    await SharedPrefHelper.clearAuthData();
  }
}