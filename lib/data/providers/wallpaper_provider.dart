import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallpaper.dart';
import '../repositories/unsplash_api.dart';
import '../repositories/pexels_api.dart';

/// Wallpapers Provider (for home page)
final wallpapersProvider = FutureProvider.family<List<Wallpaper>, int>(
  (ref, page) async {
    final unsplashPhotos = await UnsplashApi.getRandomPhotos(page: page);
    final pexelsPhotos = await PexelsApi.getCuratedPhotos(page: page);
    final all = [...unsplashPhotos, ...pexelsPhotos];
    all.shuffle();
    return all;
  },
);

/// Search Wallpapers Provider
final searchWallpapersProvider = FutureProvider.family<
    List<Wallpaper>, ({String query, int page})>(
  (ref, params) async {
    final unsplashResults = await UnsplashApi.searchPhotos(params.query, page: params.page);
    final pexelsResults = await PexelsApi.searchPhotos(params.query, page: params.page);
    return [...unsplashResults, ...pexelsResults];
  },
);

/// Random Wallpapers Provider
final randomWallpapersProvider = FutureProvider<List<Wallpaper>>((ref) async {
  return await UnsplashApi.getRandomPhotos();
});

/// Trending Wallpapers Provider
final trendingWallpapersProvider = FutureProvider<List<Wallpaper>>((ref) async {
  return await PexelsApi.getCuratedPhotos();
});
