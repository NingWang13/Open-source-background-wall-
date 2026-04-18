import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/wallpaper.dart';
import 'wallpaper_service.dart';
import 'favorites_service.dart';

/// Auto Change Settings Model
class AutoChangeSettings {
  final bool enabled;
  final int intervalMinutes;
  final bool useFavoritesOnly;
  final bool useDownloadsOnly;
  final bool includeOnline;
  final WallpaperScreen screen;

  AutoChangeSettings({
    this.enabled = false,
    this.intervalMinutes = 30,
    this.useFavoritesOnly = false,
    this.useDownloadsOnly = false,
    this.includeOnline = true,
    this.screen = WallpaperScreen.both,
  });

  AutoChangeSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    bool? useFavoritesOnly,
    bool? useDownloadsOnly,
    bool? includeOnline,
    WallpaperScreen? screen,
  }) {
    return AutoChangeSettings(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      useFavoritesOnly: useFavoritesOnly ?? this.useFavoritesOnly,
      useDownloadsOnly: useDownloadsOnly ?? this.useDownloadsOnly,
      includeOnline: includeOnline ?? this.includeOnline,
      screen: screen ?? this.screen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'intervalMinutes': intervalMinutes,
      'useFavoritesOnly': useFavoritesOnly,
      'useDownloadsOnly': useDownloadsOnly,
      'includeOnline': includeOnline,
      'screen': screen.index,
    };
  }

  factory AutoChangeSettings.fromJson(Map<String, dynamic> json) {
    return AutoChangeSettings(
      enabled: json['enabled'] ?? false,
      intervalMinutes: json['intervalMinutes'] ?? 30,
      useFavoritesOnly: json['useFavoritesOnly'] ?? false,
      useDownloadsOnly: json['useDownloadsOnly'] ?? false,
      includeOnline: json['includeOnline'] ?? true,
      screen: WallpaperScreen.values[json['screen'] ?? 0],
    );
  }
}

/// Auto Change Service for automatic wallpaper rotation
class AutoChangeService {
  static const String _keySettings = 'auto_change_settings';
  static Timer? _timer;
  static AutoChangeSettings _settings = AutoChangeSettings();
  static final _settingsController = StreamController<AutoChangeSettings>.broadcast();
  
  static Stream<AutoChangeSettings> get settingsStream => _settingsController.stream;
  static AutoChangeSettings get settings => _settings;

  /// Initialize service
  static Future<void> initialize() async {
    await _loadSettings();
    if (_settings.enabled) {
      start();
    }
  }

  /// Load settings from storage
  static Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySettings);
    if (json != null) {
      try {
        // Simple parsing - use jsonDecode in production
        _settings = AutoChangeSettings.fromJson({});
      } catch (e) {
        debugPrint('Failed to load auto change settings: $e');
      }
    }
    _settingsController.add(_settings);
  }

  /// Save settings to storage
  static Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, ''); // Use jsonEncode in production
    _settingsController.add(_settings);
  }

  /// Update settings
  static Future<void> updateSettings(AutoChangeSettings newSettings) async {
    final wasEnabled = _settings.enabled;
    _settings = newSettings;
    await _saveSettings();

    if (_settings.enabled && !wasEnabled) {
      start();
    } else if (!_settings.enabled && wasEnabled) {
      stop();
    } else if (_settings.enabled && wasEnabled) {
      // Restart with new interval
      stop();
      start();
    }
  }

  /// Start auto change
  static void start() {
    if (_timer != null) return;
    
    debugPrint('Starting auto wallpaper change every ${_settings.intervalMinutes} minutes');
    
    // Change immediately on start
    _changeWallpaper();
    
    // Schedule periodic changes
    _timer = Timer.periodic(
      Duration(minutes: _settings.intervalMinutes),
      (_) => _changeWallpaper(),
    );
  }

  /// Stop auto change
  static void stop() {
    debugPrint('Stopping auto wallpaper change');
    _timer?.cancel();
    _timer = null;
  }

  /// Change wallpaper
  static Future<void> _changeWallpaper() async {
    try {
      Wallpaper? wallpaper;
      
      if (_settings.useFavoritesOnly) {
        // Use favorites
        final favorites = FavoritesService.favorites;
        if (favorites.isNotEmpty) {
          wallpaper = favorites[Random().nextInt(favorites.length)];
        }
      } else if (_settings.useDownloadsOnly) {
        // Use downloads
        // TODO: Implement downloads service integration
      } else if (_settings.includeOnline) {
        // Fetch random online wallpaper
        // TODO: Implement random wallpaper fetch from API
      }

      if (wallpaper != null) {
        await WallpaperService.setWallpaperFromUrl(
          wallpaper.url,
          location: _settings.screen.value,
        );
        debugPrint('Auto changed wallpaper to: ${wallpaper.id}');
      }
    } catch (e) {
      debugPrint('Failed to auto change wallpaper: $e');
    }
  }

  /// Dispose service
  static void dispose() {
    stop();
    _settingsController.close();
  }
}