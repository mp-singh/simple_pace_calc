import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
    });
  }

  Future<void> _toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    setState(() {
      _themeMode = newThemeMode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newThemeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

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
