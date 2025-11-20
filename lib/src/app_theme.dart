import 'package:flutter/material.dart';

// Modern premium 2025 theme
// Palette: deep navy with soft cyan accents and warm highlights
const Color _kPrimary = Color(0xFF0B2B4A); // deep navy
const Color _kAccent = Color(0xFF00C2D1); // soft cyan

const Color _kLightBackground = Color(0xFFF7F9FB);
const Color _kLightSurface = Color(0xFFFFFFFF);

// legacy dark constants (replaced by softer variants below)

// Softer dark theme variants (easier on the eyes)
const Color _kDarkBackgroundSoft = Color(0xFF0B1B23); // soft charcoal
const Color _kDarkSurfaceSoft = Color(0xFF12262B); // slightly lighter surface
const Color _kDarkInputFill = Color(0xFF0F2329); // input fill for dark mode
const Color _kDarkOnSurface = Color(0xB3FFFFFF); // ~70% white for text
const Color _kDarkHint = Color(0x80FFFFFF); // ~50% white for hints
const Color _kDarkAccent = Color(
  0xFF089395,
); // slightly muted cyan for dark buttons

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
    onPrimary: _kDarkOnSurface,
    secondary: _kDarkAccent,
    surface: _kDarkSurfaceSoft,
    background: _kDarkBackgroundSoft,
    onSurface: _kDarkOnSurface,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: _kDarkBackgroundSoft,
    cardColor: _kDarkSurfaceSoft,
    appBarTheme: AppBarTheme(
      backgroundColor: _kDarkSurfaceSoft,
      foregroundColor: _kDarkOnSurface,
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
        backgroundColor: _kDarkAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _kDarkOnSurface,
        side: const BorderSide(color: Color(0x22FFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _kDarkInputFill,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: const TextStyle(color: _kDarkHint),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    // cards use `cardColor` and default shape; keep visuals simple and consistent
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF122B30),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: _kDarkOnSurface,
      displayColor: _kDarkOnSurface,
    ),
  );
}
