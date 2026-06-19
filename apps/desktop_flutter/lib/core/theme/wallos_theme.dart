import 'package:flutter/material.dart';

ThemeData buildWallOsTheme() {
  const seed = Color(0xFF1F7CCF);
  final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF2F7FC),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(height: 1.35),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      surfaceTintColor: Colors.white,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.72),
      indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
