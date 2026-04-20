import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhaven/core/services/favorites_service.dart';
import 'package:wallhaven/data/models/wallpaper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Wallpaper _makeWallpaper(String id) => Wallpaper(
        id: id,
        url: 'https://example.com/$id.jpg',
        thumbnailUrl: 'https://example.com/$id.thumb.jpg',
        author: 'Author $id',
        authorUrl: 'https://example.com',
        width: 1920,
        height: 1080,
      );

  // [Fix] 每个测试前重置静态状态，防止跨测试污染
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FavoritesService.resetForTesting();
  });

  group('FavoritesService', () {
    test('initialize loads favorites from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'favorites': [
          jsonEncode(_makeWallpaper('1').toJson()),
          jsonEncode(_makeWallpaper('2').toJson()),
        ],
      });

      await FavoritesService.initialize();

      expect(FavoritesService.count, 2);
      expect(FavoritesService.isFavorite('1'), isTrue);
      expect(FavoritesService.isFavorite('2'), isTrue);
      expect(FavoritesService.isFavorite('999'), isFalse);
    });

    test('initialize handles empty SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      await FavoritesService.initialize();

      expect(FavoritesService.count, 0);
      expect(FavoritesService.isEmpty, isTrue);
    });

    test('addToFavorites adds wallpaper and persists', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));

      expect(FavoritesService.count, 1);
      expect(FavoritesService.isFavorite('w1'), isTrue);
    });

    test('addToFavorites does not add duplicate', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));
      await FavoritesService.addToFavorites(_makeWallpaper('w1'));

      expect(FavoritesService.count, 1);
    });

    test('removeFromFavorites removes wallpaper and persists', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));
      expect(FavoritesService.isFavorite('w1'), isTrue);

      await FavoritesService.removeFromFavorites('w1');
      expect(FavoritesService.isFavorite('w1'), isFalse);
      expect(FavoritesService.count, 0);
    });

    test('toggleFavorite adds if not present', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      final result = await FavoritesService.toggleFavorite(_makeWallpaper('w1'));

      expect(result, isTrue);
      expect(FavoritesService.isFavorite('w1'), isTrue);
    });

    test('toggleFavorite removes if present', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));
      final result = await FavoritesService.toggleFavorite(_makeWallpaper('w1'));

      expect(result, isFalse);
      expect(FavoritesService.isFavorite('w1'), isFalse);
    });

    test('toggleFavoriteOptimistic immediately updates state', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      bool? reportedState;
      await FavoritesService.toggleFavoriteOptimistic(
        _makeWallpaper('w1'),
        (isFav) => reportedState = isFav,
      );

      expect(reportedState, isTrue);
      expect(FavoritesService.isFavorite('w1'), isTrue);
    });

    test('toggleFavoriteOptimistic removes and reports false on second call', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));

      bool? reportedState;
      await FavoritesService.toggleFavoriteOptimistic(
        _makeWallpaper('w1'),
        (isFav) => reportedState = isFav,
      );

      expect(reportedState, isFalse);
      expect(FavoritesService.isFavorite('w1'), isFalse);
    });

    test('favorites returns unmodifiable list', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));

      expect(
        () => (FavoritesService.favorites as List).add(_makeWallpaper('w2')),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('count reflects correct number of favorites', () async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesService.initialize();

      expect(FavoritesService.count, 0);

      await FavoritesService.addToFavorites(_makeWallpaper('w1'));
      expect(FavoritesService.count, 1);

      await FavoritesService.addToFavorites(_makeWallpaper('w2'));
      expect(FavoritesService.count, 2);

      await FavoritesService.removeFromFavorites('w1');
      expect(FavoritesService.count, 1);
    });
  });
}
