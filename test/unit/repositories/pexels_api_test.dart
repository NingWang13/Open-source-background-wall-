import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven/data/repositories/pexels_api.dart';

void main() {
  group('PexelsApi - Mock Data', () {
    test('getCuratedPhotos returns correct perPage count', () async {
      final photos = await PexelsApi.getCuratedPhotos(perPage: 8);
      expect(photos.length, 8);
    });

    test('getCuratedPhotos returns correct perPage count (20)', () async {
      final photos = await PexelsApi.getCuratedPhotos(perPage: 20);
      expect(photos.length, 20);
    });

    test('searchPhotos returns correct perPage count', () async {
      final results = await PexelsApi.searchPhotos('ocean', perPage: 12);
      expect(results.length, 12);
    });

    test('mock wallpapers have correct source field', () async {
      final photos = await PexelsApi.getCuratedPhotos(perPage: 3);
      for (final photo in photos) {
        expect(photo.source, 'pexels');
      }
    });

    test('mock wallpapers have unique IDs within same page', () async {
      final photos = await PexelsApi.getCuratedPhotos(perPage: 20);
      final ids = photos.map((p) => p.id).toSet();
      expect(ids.length, photos.length, reason: 'All IDs should be unique on same page');
    });

    test('mock wallpapers have valid picsum URLs', () async {
      final photos = await PexelsApi.getCuratedPhotos(perPage: 5);
      for (final photo in photos) {
        expect(photo.url, contains('picsum.photos'));
        expect(photo.thumbnailUrl, contains('picsum.photos'));
      }
    });

    test('searchPhotos returns search-related content', () async {
      final results = await PexelsApi.searchPhotos('forest', perPage: 5);
      expect(results, isNotEmpty);
      expect(results.length, 5);
    });

    test('getPhoto returns null without API key', () async {
      final photo = await PexelsApi.getPhoto('some_id');
      expect(photo, isNull);
    });
  });
}
