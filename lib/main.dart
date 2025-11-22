import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/app_theme.dart';
import 'src/home/pace_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    // Disable debug features for better performance in debug mode
    debugPrintRebuildDirtyWidgets = false;
    debugPrintBuildScope = false;
    debugPrintScheduleBuildForStacks = false;
  }
  runApp(const PaceCalculatorApp());
}

class PaceCalculatorApp extends StatefulWidget {
  const PaceCalculatorApp({super.key});

  @override
  State<PaceCalculatorApp> createState() => _PaceCalculatorAppState();
}

class _PaceCalculatorAppState extends State<PaceCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pace Calculator',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeMode,
      home: PaceHomePage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// PaceHomePage is implemented in `lib/src/home/pace_home.dart`.
