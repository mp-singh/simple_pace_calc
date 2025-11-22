import 'package:flutter/material.dart';

// Discord-inspired theme
// Palette: Discord blurple with complementary light and dark variants

// Discord-inspired light theme
const Color _kLightBackground = Color(0xFFFFFFFF);
const Color _kLightSurface = Color(0xFFF8F9FA);
const Color _kLightOnSurface = Color(0xFF2C2F33);
const Color _kLightHint = Color(0xFF72767d);

// legacy dark constants (replaced by softer variants below)

// Discord-inspired dark theme
const Color _kDiscordBackground = Color(0xFF36393f);
const Color _kDiscordSurface = Color(0xFF2f3136);
const Color _kDiscordOnSurface = Color(0xFFdcddde);
const Color _kDiscordHint = Color(0xFF72767d);
const Color _kDiscordPrimary = Color(0xFF5865f2);

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _kDiscordPrimary,
    primary: _kDiscordPrimary,
    secondary: _kDiscordPrimary,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _kLightBackground,
    cardColor: _kLightSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: _kDiscordPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kDiscordPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _kDiscordPrimary,
        side: BorderSide(color: _kDiscordPrimary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F1F3),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(color: _kLightHint),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    // cards use `cardColor` and default shape; keep visuals simple and consistent
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _kDiscordPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: _kLightOnSurface,
      displayColor: _kLightOnSurface,
    ),
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: _kDiscordPrimary,
    onPrimary: Colors.white,
    secondary: _kDiscordPrimary,
    surface: _kDiscordSurface,
    onSurface: _kDiscordOnSurface,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _kDiscordBackground,
    cardColor: _kDiscordSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: _kDiscordSurface,
      foregroundColor: _kDiscordOnSurface,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kDiscordPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _kDiscordOnSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kDiscordPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _kDiscordOnSurface,
        side: BorderSide(color: _kDiscordHint.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF202225), // tertiary background
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(color: _kDiscordHint),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    // cards use `cardColor` and default shape; keep visuals simple and consistent
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _kDiscordSurface,
      contentTextStyle: TextStyle(color: _kDiscordOnSurface),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: _kDiscordOnSurface,
      displayColor: _kDiscordOnSurface,
    ),
  );
}
