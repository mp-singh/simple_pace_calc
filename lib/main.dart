import 'package:flutter/material.dart';
import 'src/app_theme.dart';
import 'src/home/pace_home.dart';

void main() => runApp(const PaceCalculatorApp());

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
