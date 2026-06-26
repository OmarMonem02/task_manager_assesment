import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_theme_mode_usecase.dart';
import '../../domain/usecases/set_theme_mode_usecase.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemeModeUseCase _getThemeModeUseCase;
  final SetThemeModeUseCase _setThemeModeUseCase;

  ThemeCubit({
    required GetThemeModeUseCase getThemeModeUseCase,
    required SetThemeModeUseCase setThemeModeUseCase,
  })  : _getThemeModeUseCase = getThemeModeUseCase,
        _setThemeModeUseCase = setThemeModeUseCase,
        super(ThemeMode.light);

  Future<void> loadTheme() async {
    final mode = await _getThemeModeUseCase();
    emit(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _setThemeModeUseCase(mode);
    emit(mode);
  }

  Future<void> toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    return setTheme(next);
  }
}
