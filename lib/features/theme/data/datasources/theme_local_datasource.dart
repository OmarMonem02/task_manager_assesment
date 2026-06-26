import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/theme_storage.dart';

abstract class ThemeLocalDataSource {
  Future<String?> getThemeMode();
  Future<void> saveThemeMode(String mode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  ThemeLocalDataSourceImpl(this._themeStorage);

  final ThemeStorage _themeStorage;

  @override
  Future<String?> getThemeMode() => _themeStorage.getThemeMode();

  @override
  Future<void> saveThemeMode(String mode) async {
    try {
      await _themeStorage.saveThemeMode(mode);
    } catch (e) {
      throw CacheException('Failed to save theme mode');
    }
  }
}
