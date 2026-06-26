import 'package:flutter/material.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl({required ThemeLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<ThemeMode> getThemeMode() async {
    final stored = await _localDataSource.getThemeMode();
    return switch (stored) {
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    return _localDataSource.saveThemeMode(value);
  }
}
