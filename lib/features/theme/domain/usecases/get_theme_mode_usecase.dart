import 'package:flutter/material.dart';
import '../repositories/theme_repository.dart';

class GetThemeModeUseCase {
  final ThemeRepository _repository;

  GetThemeModeUseCase(this._repository);

  Future<ThemeMode> call() => _repository.getThemeMode();
}
