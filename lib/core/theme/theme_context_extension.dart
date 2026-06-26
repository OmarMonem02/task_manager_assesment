import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

extension ThemeContext on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>()!;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
