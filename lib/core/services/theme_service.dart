import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Service for managing app theme
class ThemeService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAccentColor = 'accent_color';
  
  static final _themeController = StreamController<ThemeMode>.broadcast();
  static Stream<ThemeMode> get themeStream => _themeController.stream;
  static ThemeMode _currentMode = ThemeMode.system;

  /// Initialize theme service
  static Future<void> initialize() async {
    _currentMode = await getThemeMode();
    _themeController.add(_currentMode);
  }

  /// Get saved theme mode
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode) ?? 0;
    return ThemeMode.values[index];
  }

  /// Set theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    _themeController.add(mode);
  }

  /// Toggle between light and dark
  static Future<ThemeMode> toggleTheme(BuildContext context) async {
    final currentMode = await getThemeMode();
    ThemeMode newMode;
    
    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // System mode - check current brightness
      final brightness = MediaQuery.platformBrightnessOf(context);
      newMode = brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
    }
    
    await setThemeMode(newMode);
    return newMode;
  }

  /// Get accent color
  static Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyAccentColor);
    return value != null ? Color(value) : Colors.blue;
  }

  /// Set accent color
  static Future<void> setAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAccentColor, color.value);
  }

  /// Available accent colors
  static List<Color> get availableColors => [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
  ];
}