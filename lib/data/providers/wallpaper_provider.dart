import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallpaper.dart';
import '../repositories/unsplash_api.dart';
import '../repositories/pexels_api.dart';

/// Wallpapers Provider (for home page)
/// [Fix] 使用 Future.wait 并行请求，并按 ID 去重
final wallpapersProvider = FutureProvider.family<List<Wallpaper>, int>(
  (ref, page) async {
    final results = await Future.wait([
      UnsplashApi.getRandomPhotos(page: page, perPage: 20),
      PexelsApi.getCuratedPhotos(page: page, perPage: 20),
    ]);

    final all = [...results[0], ...results[1]];

    // [Fix] 按 ID 去重
    final seenIds = <String>{};
    final deduped = all.where((w) {
      if (seenIds.contains(w.id)) return false;
      seenIds.add(w.id);
      return true;
    }).toList();

    deduped.shuffle();
    return deduped;
  },
);

/// Search Wallpapers Provider
/// [Fix] 使用 Future.wait 并行请求，并按 ID 去重
final searchWallpapersProvider = FutureProvider.family<
    List<Wallpaper>, ({String query, int page})>(
  (ref, params) async {
    final results = await Future.wait([
      UnsplashApi.searchPhotos(params.query, page: params.page, perPage: 20),
      PexelsApi.searchPhotos(params.query, page: params.page, perPage: 20),
    ]);

    final all = [...results[0], ...results[1]];

    // [Fix] 按 ID 去重
    final seenIds = <String>{};
    final deduped = all.where((w) {
      if (seenIds.contains(w.id)) return false;
      seenIds.add(w.id);
      return true;
    }).toList();

    return deduped;
  },
);

/// Random Wallpapers Provider
/// [Fix] 增加去重逻辑
final randomWallpapersProvider = FutureProvider<List<Wallpaper>>((ref) async {
  final results = await Future.wait([
    UnsplashApi.getRandomPhotos(perPage: 30),
    PexelsApi.getCuratedPhotos(perPage: 30),
  ]);

  final all = [...results[0], ...results[1]];

  final seenIds = <String>{};
  final deduped = all.where((w) {
    if (seenIds.contains(w.id)) return false;
    seenIds.add(w.id);
    return true;
  }).toList();

  deduped.shuffle();
  return deduped;
});

/// Trending Wallpapers Provider
/// [Fix] 增加去重逻辑
final trendingWallpapersProvider = FutureProvider<List<Wallpaper>>((ref) async {
  final results = await Future.wait([
    UnsplashApi.getRandomPhotos(perPage: 30),
    PexelsApi.getCuratedPhotos(perPage: 30),
  ]);

  final all = [...results[0], ...results[1]];

  final seenIds = <String>{};
  final deduped = all.where((w) {
    if (seenIds.contains(w.id)) return false;
    seenIds.add(w.id);
    return true;
  }).toList();

  // 按点赞数排序
  deduped.sort((a, b) => b.likes.compareTo(a.likes));
  return deduped;
});
