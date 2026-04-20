import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/wallpaper.dart';

/// 收藏服务
/// [Fix 15] 新增乐观更新模式 toggleFavoriteOptimistic
class FavoritesService {
  static const String _keyFavorites = 'favorites';
  static final List<Wallpaper> _favorites = [];

  /// 测试用：重置内存状态（测试隔离）
  @visibleForTesting
  static void resetForTesting() {
    _favorites.clear();
  }
  static final _favoritesController = StreamController<List<Wallpaper>>.broadcast();

  static Stream<List<Wallpaper>> get favoritesStream => _favoritesController.stream;
  static List<Wallpaper> get favorites => List.unmodifiable(_favorites);
  static bool get isEmpty => _favorites.isEmpty;
  static int get count => _favorites.length;

  /// 初始化（main.dart 启动时调用一次，不要在页面内重复调用）
  static Future<void> initialize() async {
    // 防止重复初始化
    if (_favorites.isNotEmpty) return;

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

  /// 切换收藏状态（传统模式，返回最终状态）
  static Future<bool> toggleFavorite(Wallpaper wallpaper) async {
    if (isFavorite(wallpaper.id)) {
      await removeFromFavorites(wallpaper.id);
      return false;
    } else {
      await addToFavorites(wallpaper);
      return true;
    }
  }

  /// 切换收藏状态 - 乐观更新模式
  /// [Fix 15] 立即更新 UI（乐观），存储失败时回滚
  /// [wallpaper] 要切换的壁纸
  /// [onStateChange] 状态变更回调，传入最终是否为收藏状态
  static Future<bool> toggleFavoriteOptimistic(
    Wallpaper wallpaper,
    void Function(bool isFav)? onStateChange,
  ) async {
    final wasFav = isFavorite(wallpaper.id);

    // 乐观更新：立即在内存中反映变化
    if (wasFav) {
      _favorites.removeWhere((w) => w.id == wallpaper.id);
    } else {
      _favorites.add(wallpaper);
    }
    // 立即通知 UI
    onStateChange?.call(!wasFav);
    _favoritesController.add(List.unmodifiable(_favorites));

    try {
      await _saveFavorites();
      return !wasFav;
    } catch (e) {
      // 存储失败，回滚内存状态
      if (wasFav) {
        _favorites.add(wallpaper);
      } else {
        _favorites.removeWhere((w) => w.id == wallpaper.id);
      }
      onStateChange?.call(wasFav); // 恢复 UI
      _favoritesController.add(List.unmodifiable(_favorites));
      debugPrint('Failed to persist favorite toggle: $e');
      return wasFav;
    }
  }

  /// 保存到本地
  static Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((w) => json.encode(w.toJson())).toList();
    await prefs.setStringList(_keyFavorites, jsonList);
  }
}
