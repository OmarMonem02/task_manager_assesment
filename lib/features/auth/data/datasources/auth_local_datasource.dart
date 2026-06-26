import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/session_storage.dart';

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
  Future<int?> getUserId();
  Future<bool> isLoggedIn();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._sessionStorage);

  final SessionStorage _sessionStorage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    try {
      await _sessionStorage.saveAccessToken(accessToken);
      await _sessionStorage.saveRefreshToken(refreshToken);
      await _sessionStorage.saveUserId(userId);
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
      await _sessionStorage.saveUserProfile(
        username: username,
        email: email,
      );
    } catch (e) {
      throw CacheException('Failed to save user profile');
    }
  }

  @override
  Future<Map<String, String>?> getUserProfile() =>
      _sessionStorage.getUserProfile();

  @override
  Future<String?> getAccessToken() => _sessionStorage.getAccessToken();

  @override
  Future<int?> getUserId() => _sessionStorage.getUserId();

  @override
  Future<bool> isLoggedIn() async {
    final token = await _sessionStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearTokens() async {
    await _sessionStorage.clearAuthData();
  }
}
