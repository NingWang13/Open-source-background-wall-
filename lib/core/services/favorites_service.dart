import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/wallpaper.dart';

/// 收藏服务
class FavoritesService {
  static const String _keyFavorites = 'favorites';
  static final List<Wallpaper> _favorites = [];
  static final _favoritesController = StreamController<List<Wallpaper>>.broadcast();

  static Stream<List<Wallpaper>> get favoritesStream => _favoritesController.stream;
  static List<Wallpaper> get favorites => List.unmodifiable(_favorites);
  static bool get isEmpty => _favorites.isEmpty;
  static int get count => _favorites.length;

  /// 初始化
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_keyFavorites) ?? [];

    _favorites.clear();
    for (final jsonStr in favoritesJson) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        _favorites.add(Wallpaper.fromJson(map));
      } catch (e) {
        debugPrint('Failed to parse favorite: $e');
      }
    }

    _favoritesController.add(List.unmodifiable(_favorites));
  }

  /// 添加到收藏
  static Future<void> addToFavorites(Wallpaper wallpaper) async {
    if (_favorites.any((w) => w.id == wallpaper.id)) return;

    _favorites.add(wallpaper);
    await _saveFavorites();
    _favoritesController.add(List.unmodifiable(_favorites));
  }

  /// 移除收藏
  static Future<void> removeFromFavorites(String wallpaperId) async {
    _favorites.removeWhere((w) => w.id == wallpaperId);
    await _saveFavorites();
    _favoritesController.add(List.unmodifiable(_favorites));
  }

  /// 是否已收藏
  static bool isFavorite(String wallpaperId) {
    return _favorites.any((w) => w.id == wallpaperId);
  }

  /// 切换收藏状态
  static Future<bool> toggleFavorite(Wallpaper wallpaper) async {
    if (isFavorite(wallpaper.id)) {
      await removeFromFavorites(wallpaper.id);
      return false;
    } else {
      await addToFavorites(wallpaper);
      return true;
    }
  }

  /// 保存到本地
  static Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((w) => json.encode(w.toJson())).toList();
    await prefs.setStringList(_keyFavorites, jsonList);
  }
}
