import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven/data/models/wallpaper.dart';

void main() {
  group('Wallpaper Model', () {
    test('fromJson creates correct instance from Unsplash-like JSON', () {
      final json = {
        'id': 'abc123',
        'url': 'https://example.com/original.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'author': 'John Doe',
        'authorUrl': 'https://unsplash.com/@john',
        'width': 1920,
        'height': 1080,
        'description': 'A beautiful landscape',
        'color': '#1a2b3c',
        'tags': ['nature', 'mountain'],
        'likes': 42,
        'downloads': 100,
        'created_at': '2024-01-15T10:00:00Z',
        'source': 'unsplash',
      };

      final wallpaper = Wallpaper.fromJson(json);

      expect(wallpaper.id, 'abc123');
      expect(wallpaper.url, 'https://example.com/original.jpg');
      expect(wallpaper.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(wallpaper.author, 'John Doe');
      expect(wallpaper.width, 1920);
      expect(wallpaper.height, 1080);
      expect(wallpaper.description, 'A beautiful landscape');
      expect(wallpaper.color, '#1a2b3c');
      expect(wallpaper.tags, ['nature', 'mountain']);
      expect(wallpaper.likes, 42);
      expect(wallpaper.source, 'unsplash');
      expect(wallpaper.createdAt, isNotNull);
    });

    test('fromJson handles Pexels-like JSON with thumbnail_url', () {
      final json = {
        'id': 'pexels_456',
        'url': 'https://example.com/original.jpg',
        'thumbnail_url': 'https://example.com/medium.jpg',
        'author': 'Jane Smith',
        'authorUrl': 'https://pexels.com/@jane',
        'width': 2560,
        'height': 1440,
        'alt_description': 'Ocean waves',
        'avg_color': '#334455',
        'likes': 15,
        'downloads': 50,
        'source': 'pexels',
      };

      final wallpaper = Wallpaper.fromJson(json);

      expect(wallpaper.thumbnailUrl, 'https://example.com/medium.jpg');
      expect(wallpaper.description, 'Ocean waves');
      expect(wallpaper.color, '#334455');
      expect(wallpaper.width, 2560);
    });

    test('fromJson handles missing optional fields', () {
      final wallpaper = Wallpaper.fromJson({
        'id': 'minimal_123',
        'url': 'https://example.com/img.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'author': 'Anon',
        'authorUrl': '',
      });

      expect(wallpaper.id, 'minimal_123');
      expect(wallpaper.description, isNull);
      expect(wallpaper.color, isNull);
      expect(wallpaper.tags, isEmpty);
      expect(wallpaper.likes, 0);
      expect(wallpaper.downloads, 0);
      expect(wallpaper.createdAt, isNull);
    });

    test('fromJson handles empty/invalid JSON gracefully', () {
      final wallpaper = Wallpaper.fromJson({});
      expect(wallpaper.id, '');
      expect(wallpaper.url, '');
      expect(wallpaper.author, '');
    });

    test('toJson produces correct output', () {
      final wallpaper = Wallpaper(
        id: 'test_id',
        url: 'https://test.com/img.jpg',
        thumbnailUrl: 'https://test.com/thumb.jpg',
        author: 'Test Author',
        authorUrl: 'https://test.com',
        width: 3840,
        height: 2160,
        description: 'Test desc',
        color: '#ff0000',
        tags: ['test'],
        likes: 10,
        downloads: 5,
        source: 'unsplash',
      );

      final json = wallpaper.toJson();

      expect(json['id'], 'test_id');
      expect(json['url'], 'https://test.com/img.jpg');
      expect(json['author'], 'Test Author');
      expect(json['color'], '#ff0000');
      expect(json['source'], 'unsplash');
    });

    test('aspectRatio returns correct value for 16:9', () {
      final wallpaper = Wallpaper(
        id: '1',
        url: '',
        thumbnailUrl: '',
        author: '',
        authorUrl: '',
        width: 1920,
        height: 1080,
      );
      expect(wallpaper.aspectRatio, closeTo(1.778, 0.01));
    });

    test('aspectRatioText returns ratio strings for common dimensions', () {
      // 16:9 → shows as "16:9"
      expect(_makeWallpaper(1920, 1080).aspectRatioText, '16:9');
      // 4:3 → shows as "4:3"
      expect(_makeWallpaper(1600, 1200).aspectRatioText, '4:3');
      // 1:1 → shows as "1:1"
      expect(_makeWallpaper(1000, 1000).aspectRatioText, '1:1');
      // Non-standard ratios show exact dimensions
      expect(_makeWallpaper(2560, 1080).aspectRatioText, '2560:1080');
    });

    test('resolutionText returns correct labels', () {
      expect(_makeWallpaper(1920, 1080).resolutionText, '1080p');
      expect(_makeWallpaper(2560, 1440).resolutionText, '2K');
      expect(_makeWallpaper(3840, 2160).resolutionText, '4K');
      expect(_makeWallpaper(800, 600).resolutionText, '800x600');
    });

    test('equality is based on id', () {
      final w1 = Wallpaper(id: 'same_id', url: 'url1', thumbnailUrl: '', author: 'a', authorUrl: '', width: 1920, height: 1080);
      final w2 = Wallpaper(id: 'same_id', url: 'url2', thumbnailUrl: '', author: 'b', authorUrl: '', width: 2560, height: 1440);
      final w3 = Wallpaper(id: 'different_id', url: 'url1', thumbnailUrl: '', author: 'a', authorUrl: '', width: 1920, height: 1080);

      expect(w1 == w2, isTrue);
      expect(w1 == w3, isFalse);
      expect(w1.hashCode, w2.hashCode);
    });
  });
}

Wallpaper _makeWallpaper(int width, int height) => Wallpaper(
      id: '${width}x$height',
      url: '',
      thumbnailUrl: '',
      author: '',
      authorUrl: '',
      width: width,
      height: height,
    );
