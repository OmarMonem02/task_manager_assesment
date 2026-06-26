import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';
import 'session_storage.dart';
import 'theme_storage.dart';

class SharedPreferencesLocalStorage implements LocalStorage {
  SharedPreferencesLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesLocalStorage(prefs);
  }

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._storage);

  final LocalStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.setString(_accessTokenKey, token);

  @override
  Future<String?> getAccessToken() => _storage.getString(_accessTokenKey);

  @override
  Future<void> saveRefreshToken(String token) =>
      _storage.setString(_refreshTokenKey, token);

  @override
  Future<String?> getRefreshToken() => _storage.getString(_refreshTokenKey);

  @override
  Future<void> saveUserId(int id) => _storage.setInt(_userIdKey, id);

  @override
  Future<int?> getUserId() => _storage.getInt(_userIdKey);

  @override
  Future<void> saveUserProfile({
    required String username,
    required String email,
  }) async {
    await _storage.setString(_usernameKey, username);
    await _storage.setString(_emailKey, email);
  }

  @override
  Future<Map<String, String>?> getUserProfile() async {
    final username = await _storage.getString(_usernameKey);
    final email = await _storage.getString(_emailKey);
    if (username == null || email == null) return null;
    return {'username': username, 'email': email};
  }

  @override
  Future<void> clearAuthData() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_userIdKey);
    await _storage.remove(_usernameKey);
    await _storage.remove(_emailKey);
  }
}

class SharedPreferencesThemeStorage implements ThemeStorage {
  SharedPreferencesThemeStorage(this._storage);

  final LocalStorage _storage;

  static const _themeModeKey = 'theme_mode';

  @override
  Future<void> saveThemeMode(String mode) =>
      _storage.setString(_themeModeKey, mode);

  @override
  Future<String?> getThemeMode() => _storage.getString(_themeModeKey);
}
