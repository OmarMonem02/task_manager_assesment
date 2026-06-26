import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/shared_pref_helper.dart';

abstract class ThemeLocalDataSource {
  Future<String?> getThemeMode();
  Future<void> saveThemeMode(String mode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  @override
  Future<String?> getThemeMode() => SharedPrefHelper.getThemeMode();

  @override
  Future<void> saveThemeMode(String mode) async {
    try {
      await SharedPrefHelper.saveThemeMode(mode);
    } catch (e) {
      throw CacheException('Failed to save theme mode');
    }
  }
}
