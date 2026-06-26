import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color scaffoldBackground;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color appBarBackground;
  final Color cardShadow;
  final Color inputFill;
  final Color inputBorder;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color iconMuted;
  final Color divider;

  const AppThemeExtension({
    required this.scaffoldBackground,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.appBarBackground,
    required this.cardShadow,
    required this.inputFill,
    required this.inputBorder,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.iconMuted,
    required this.divider,
  });

  static const light = AppThemeExtension(
    scaffoldBackground: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF1A1A2E),
    secondaryText: Color(0xFF757575),
    appBarBackground: Color(0xFFFFFFFF),
    cardShadow: Color(0x0D000000),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFEEEEEE),
    skeletonBase: Color(0xFFE0E0E0),
    skeletonHighlight: Color(0xFFF5F5F5),
    iconMuted: Color(0xFFBDBDBD),
    divider: Color(0xFFE0E0E0),
  );

  static const dark = AppThemeExtension(
    scaffoldBackground: Color(0xFF121218),
    surface: Color.fromARGB(255, 32, 32, 36),
    primaryText: Color(0xFFF0F0F5),
    secondaryText: Color(0xFFB0B0B8),
    appBarBackground: Color(0xFF1E1E2E),
    cardShadow: Color(0x33000000),
    inputFill: Color(0xFF2A2A3C),
    inputBorder: Color(0xFF3A3A4C),
    skeletonBase: Color(0xFF2A2A3C),
    skeletonHighlight: Color(0xFF3A3A4C),
    iconMuted: Color(0xFF6E6E7A),
    divider: Color(0xFF3A3A4C),
  );

  @override
  AppThemeExtension copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? primaryText,
    Color? secondaryText,
    Color? appBarBackground,
    Color? cardShadow,
    Color? inputFill,
    Color? inputBorder,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? iconMuted,
    Color? divider,
  }) {
    return AppThemeExtension(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      cardShadow: cardShadow ?? this.cardShadow,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      iconMuted: iconMuted ?? this.iconMuted,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      appBarBackground:
          Color.lerp(appBarBackground, other.appBarBackground, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
