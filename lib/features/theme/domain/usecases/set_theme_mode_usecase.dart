import 'package:flutter/material.dart';
import '../repositories/theme_repository.dart';

class SetThemeModeUseCase {
  final ThemeRepository _repository;

  SetThemeModeUseCase(this._repository);

  Future<void> call(ThemeMode mode) => _repository.setThemeMode(mode);
}
