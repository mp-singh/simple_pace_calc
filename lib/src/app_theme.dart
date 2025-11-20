import 'package:flutter/material.dart';

// Modern premium 2025 theme
// Palette: deep navy with soft cyan accents and warm highlights
const Color _kPrimary = Color(0xFF0B2B4A); // deep navy
const Color _kAccent = Color(0xFF00C2D1); // soft cyan

const Color _kLightBackground = Color(0xFFF7F9FB);
const Color _kLightSurface = Color(0xFFFFFFFF);

const Color _kDarkBackground = Color(0xFF020617);
const Color _kDarkSurface = Color(0xFF0B1724);

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _kPrimary,
    primary: _kPrimary,
    secondary: _kAccent,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _kLightBackground,
    cardColor: _kLightSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: _kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kAccent),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _kPrimary,
        // 12% opacity over primary — use ARGB literal to avoid deprecated channel access
        side: const BorderSide(color: Color(0x1F0B2B4A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F8),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(color: const Color.fromRGBO(0, 0, 0, 0.45)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    // cards use `cardColor` and default shape; keep visuals simple and consistent
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _kPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
  );
}

ThemeData darkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: _kPrimary,
    onPrimary: Colors.white,
    secondary: _kAccent,
    surface: _kDarkSurface,
    onSurface: Colors.white70,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _kDarkBackground,
    cardColor: _kDarkSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: _kDarkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kAccent),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF07121A),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: Colors.white30),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    // cards use `cardColor` and default shape; keep visuals simple and consistent
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white10,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
