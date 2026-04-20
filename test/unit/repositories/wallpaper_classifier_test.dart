import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven/data/models/wallpaper.dart';
import 'package:wallhaven/data/repositories/wallpaper_classifier.dart';

void main() {
  Wallpaper _makeWallpaper({
    required String id,
    String description = '',
    String author = '',
    List<String> tags = const [],
  }) =>
      Wallpaper(
        id: id,
        url: 'https://example.com/$id.jpg',
        thumbnailUrl: 'https://example.com/$id.thumb.jpg',
        author: author,
        authorUrl: 'https://example.com',
        width: 1920,
        height: 1080,
        description: description,
        tags: tags,
      );

  group('WallpaperClassifier', () {
    test('categories contains expected items', () {
      expect(WallpaperClassifier.categories, contains('全部'));
      expect(WallpaperClassifier.categories, contains('自然'));
      expect(WallpaperClassifier.categories, contains('城市'));
      expect(WallpaperClassifier.categories, contains('动物'));
      expect(WallpaperClassifier.categories, contains('艺术'));
      expect(WallpaperClassifier.categories, contains('科技'));
      expect(WallpaperClassifier.categories, contains('美女'));
      expect(WallpaperClassifier.categories, contains('汽车'));
    });

    test('"全部" returns true for any wallpaper', () {
      final w = _makeWallpaper(id: '1', description: 'random stuff');
      expect(WallpaperClassifier.matches('全部', w), isTrue);
    });

    test('filters "自然" wallpapers by description keyword', () {
      final nature = _makeWallpaper(id: '1', description: 'A beautiful nature landscape with forest');
      final city = _makeWallpaper(id: '2', description: 'A bustling city with neon lights');

      expect(WallpaperClassifier.matches('自然', nature), isTrue);
      expect(WallpaperClassifier.matches('自然', city), isFalse);
    });

    test('filters "自然" wallpapers by tags', () {
      final withTag = _makeWallpaper(id: '1', tags: ['ocean', 'beach', 'nature']);
      final withoutTag = _makeWallpaper(id: '2', tags: ['car', 'racing']);

      expect(WallpaperClassifier.matches('自然', withTag), isTrue);
      expect(WallpaperClassifier.matches('自然', withoutTag), isFalse);
    });

    test('filters "城市" wallpapers by description', () {
      final city = _makeWallpaper(id: '1', description: 'Urban cityscape at night with neon');
      final nature = _makeWallpaper(id: '2', description: 'Mountain forest river');

      expect(WallpaperClassifier.matches('城市', city), isTrue);
      expect(WallpaperClassifier.matches('城市', nature), isFalse);
    });

    test('filters "科技" wallpapers by description', () {
      final tech = _makeWallpaper(id: '1', description: 'Technology and digital cyber space');
      final art = _makeWallpaper(id: '2', description: 'Colorful abstract painting');

      expect(WallpaperClassifier.matches('科技', tech), isTrue);
      expect(WallpaperClassifier.matches('科技', art), isFalse);
    });

    test('filters "动物" wallpapers by description and tags', () {
      final animal = _makeWallpaper(id: '1', description: 'Wild lion in the savanna', tags: ['wildlife']);
      final car = _makeWallpaper(id: '2', description: 'Sports car racing', tags: ['racing']);

      expect(WallpaperClassifier.matches('动物', animal), isTrue);
      expect(WallpaperClassifier.matches('动物', car), isFalse);
    });

    test('filters "汽车" wallpapers by description', () {
      final car = _makeWallpaper(id: '1', description: 'Sports car motorcycle racing vehicle');
      final nature = _makeWallpaper(id: '2', description: 'Mountain landscape');

      expect(WallpaperClassifier.matches('汽车', car), isTrue);
      expect(WallpaperClassifier.matches('汽车', nature), isFalse);
    });

    test('filter returns all wallpapers when category is "全部"', () {
      final wallpapers = [
        _makeWallpaper(id: '1', description: 'city'),
        _makeWallpaper(id: '2', description: 'nature'),
        _makeWallpaper(id: '3', description: 'animal'),
      ];

      final result = WallpaperClassifier.filter(wallpapers, '全部');
      expect(result.length, 3);
    });

    test('filter returns only matching wallpapers', () {
      final wallpapers = [
        _makeWallpaper(id: '1', description: 'A beautiful nature landscape'),
        _makeWallpaper(id: '2', description: 'A bustling city street'),
        _makeWallpaper(id: '3', description: 'Wild animal in the wild'),
      ];

      final result = WallpaperClassifier.filter(wallpapers, '自然');
      expect(result.length, 2); // #1 (nature) and #3 (wild animal)
    });

    test('filter returns empty list when nothing matches', () {
      final wallpapers = [
        _makeWallpaper(id: '1', description: 'City urban building'),
        _makeWallpaper(id: '2', description: 'Neon night street'),
      ];

      final result = WallpaperClassifier.filter(wallpapers, '动物');
      expect(result, isEmpty);
    });

    test('filter is case-insensitive', () {
      final wallpapers = [
        _makeWallpaper(id: '1', description: 'NATURE beautiful landscape'),
        _makeWallpaper(id: '2', description: 'CITY night lights'),
      ];

      expect(WallpaperClassifier.matches('自然', wallpapers[0]), isTrue);
      expect(WallpaperClassifier.matches('城市', wallpapers[1]), isTrue);
    });

    test('filter checks author name as search text', () {
      final wallpapers = [
        _makeWallpaper(id: '1', author: 'Nature Photographer'),
        _makeWallpaper(id: '2', author: 'City Explorer'),
      ];

      expect(WallpaperClassifier.matches('自然', wallpapers[0]), isTrue);
      expect(WallpaperClassifier.matches('城市', wallpapers[1]), isTrue);
    });
  });
}
