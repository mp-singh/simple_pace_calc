import 'package:flutter/material.dart';

// Theme colors (Strava-like dark accent)
const Color _kAccentOrange = Color(0xFFFC4C02);
const Color _kDarkBackground = Color(0xFF0B0D0F);
const Color _kDarkSurface = Color(0xFF111315);

ThemeData lightTheme() {
  return ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _kAccentOrange,
      brightness: Brightness.light,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData.from(
    colorScheme: ColorScheme.dark(
      primary: _kAccentOrange,
      onPrimary: Colors.black,
      secondary: _kAccentOrange,
      surface: _kDarkSurface,
      onSurface: Colors.white70,
      brightness: Brightness.dark,
    ),
  ).copyWith(
    scaffoldBackgroundColor: _kDarkBackground,
    cardColor: const Color(0xFF0E1012),
    appBarTheme: AppBarTheme(
      backgroundColor: _kDarkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kAccentOrange),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kAccentOrange,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D0F11),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      hintStyle: const TextStyle(color: Colors.white30),
    ),
  );
}
