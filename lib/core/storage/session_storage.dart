abstract class SessionStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUserId(int id);
  Future<int?> getUserId();
  Future<void> saveUserProfile({
    required String username,
    required String email,
  });
  Future<Map<String, String>?> getUserProfile();
  Future<void> clearAuthData();
}
