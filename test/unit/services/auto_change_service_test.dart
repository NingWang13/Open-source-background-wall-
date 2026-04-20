import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhaven/core/services/auto_change_service.dart';
import 'package:wallhaven/core/services/wallpaper_service.dart' show WallpaperScreen;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoChangeSettings', () {
    test('default values are correct', () {
      final settings = AutoChangeSettings();
      expect(settings.enabled, false);
      expect(settings.intervalMinutes, 30);
      expect(settings.useFavoritesOnly, false);
      expect(settings.includeOnline, true);
    });

    test('copyWith creates new instance with updated values', () {
      final original = AutoChangeSettings();
      final updated = original.copyWith(
        enabled: true,
        intervalMinutes: 60,
        useFavoritesOnly: true,
      );

      expect(updated.enabled, true);
      expect(updated.intervalMinutes, 60);
      expect(updated.useFavoritesOnly, true);
      expect(updated.includeOnline, true);
      expect(updated.screen, original.screen);
    });

    test('toJson serializes all fields correctly', () {
      final settings = AutoChangeSettings(
        enabled: true,
        intervalMinutes: 120,
        useFavoritesOnly: true,
        useDownloadsOnly: false,
        includeOnline: false,
        screen: WallpaperScreen.home,
      );

      final json = settings.toJson();

      expect(json['enabled'], true);
      expect(json['intervalMinutes'], 120);
      expect(json['useFavoritesOnly'], true);
      expect(json['useDownloadsOnly'], false);
      expect(json['includeOnline'], false);
      expect(json['screen'], WallpaperScreen.home.index);
    });

    test('fromJson deserializes screen=0 to WallpaperScreen.home', () {
      // [Fix] screen: 0 → home (index 0), screen: 1 → lock
      final json = {
        'enabled': true,
        'intervalMinutes': 45,
        'useFavoritesOnly': true,
        'useDownloadsOnly': true,
        'includeOnline': false,
        'screen': 0,
      };

      final settings = AutoChangeSettings.fromJson(json);

      expect(settings.enabled, true);
      expect(settings.intervalMinutes, 45);
      expect(settings.screen, WallpaperScreen.home);
    });

    test('fromJson deserializes screen=1 to WallpaperScreen.lock', () {
      final json = {
        'screen': 1,
      };

      final settings = AutoChangeSettings.fromJson(json);
      expect(settings.screen, WallpaperScreen.lock);
    });

    test('fromJson uses defaults for missing fields', () {
      final settings = AutoChangeSettings.fromJson({});

      expect(settings.enabled, false);
      expect(settings.intervalMinutes, 30);
      expect(settings.useFavoritesOnly, false);
      // json['screen'] 为 null → defaults to 0 (home)
      expect(settings.screen.index, 0);
    });

    test('roundtrip: toJson -> fromJson preserves data', () {
      final original = AutoChangeSettings(
        enabled: true,
        intervalMinutes: 90,
        useFavoritesOnly: true,
        useDownloadsOnly: false,
        includeOnline: false,
        screen: WallpaperScreen.lock,
      );

      final json = original.toJson();
      final restored = AutoChangeSettings.fromJson(json);

      expect(restored.enabled, original.enabled);
      expect(restored.intervalMinutes, original.intervalMinutes);
      expect(restored.useFavoritesOnly, original.useFavoritesOnly);
      expect(restored.screen, original.screen);
    });
  });

  group('AutoChangeService Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('updateSettings persists settings via SharedPreferences', () async {
      await AutoChangeService.updateSettings(
        AutoChangeSettings(enabled: true, intervalMinutes: 60),
      );

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('auto_change_settings');

      expect(stored, isNotNull);
      expect(stored, isNotEmpty);

      final json = jsonDecode(stored!) as Map<String, dynamic>;
      expect(json['enabled'], true);
      expect(json['intervalMinutes'], 60);
    });

    test('settings getter returns current settings', () async {
      await AutoChangeService.updateSettings(
        AutoChangeSettings(enabled: true),
      );

      expect(AutoChangeService.settings.enabled, true);
    });

    test('screen enum values are correct', () {
      expect(WallpaperScreen.home.index, 0);
      expect(WallpaperScreen.lock.index, 1);
      expect(WallpaperScreen.both.index, 2);
    });
  });
}
