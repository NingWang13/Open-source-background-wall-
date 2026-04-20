import 'package:flutter/material.dart';

/// App Constants
class AppConstants {
  AppConstants._();

  // ==================== API Key 配置 ====================
  // ⚠️ 请替换为你自己的 API Key（免费注册获取）
  // Unsplash: https://unsplash.com/developers
  // Pexels: https://www.pexels.com/api/
  //
  // 环境变量方式（推荐）：
  //   flutter run --dart-define=UNSPLASH_KEY=your_key
  //   flutter run --dart-define=PEXELS_KEY=your_key
  //
  // 使用方式：
  //   const String.fromEnvironment('UNSPLASH_KEY', defaultValue: '')
  // ==================== API Key 配置 ====================
  static const String unsplashAccessKey = String.fromEnvironment(
    'UNSPLASH_KEY',
    defaultValue: '',
  );

  static const String pexelsApiKey = String.fromEnvironment(
    'PEXELS_KEY',
    defaultValue: '',
  );

  // API 状态检查
  static bool get hasUnsplashKey =>
      unsplashAccessKey.isNotEmpty &&
      unsplashAccessKey != 'YOUR_UNSPLASH_ACCESS_KEY';

  static bool get hasPexelsKey =>
      pexelsApiKey.isNotEmpty &&
      pexelsApiKey != 'YOUR_PEXELS_API_KEY';

  static bool get hasAnyApiKey => hasUnsplashKey || hasPexelsKey;

  // App Info
  static const String appName = 'Wallhaven';
  static const String appVersion = '1.0.0';
  static const String appDescription = '免费跨平台壁纸应用';

  // API Endpoints
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
  static const String pexelsBaseUrl = 'https://api.pexels.com/v1';

  // Wallpaper Resolutions
  static const Map<String, String> resolutions = {
    'original': '原画质',
    '2k': '2K (2560x1440)',
    '4k': '4K (3840x2160)',
  };

  // Categories
  static const List<String> categories = [
    '全部', '自然', '建筑', '科技', '动物', '人物', '抽象', '游戏', '电影', '动漫',
  ];

  // Colors for filtering
  static final List<Map<String, dynamic>> filterColors = [
    {'name': '全部', 'color': null},
    {'name': '黑色', 'color': Colors.black},
    {'name': '白色', 'color': Colors.white},
    {'name': '红色', 'color': Colors.red},
    {'name': '蓝色', 'color': Colors.blue},
    {'name': '绿色', 'color': Colors.green},
    {'name': '黄色', 'color': Colors.yellow},
    {'name': '紫色', 'color': Colors.purple},
    {'name': '橙色', 'color': Colors.orange},
    {'name': '粉色', 'color': Colors.pink},
  ];

  // Storage Keys
  static const String keyFavorites = 'favorites';
  static const String keyDownloads = 'downloads';
  static const String keyUserSettings = 'user_settings';
  static const String keyDisclaimerAccepted = 'disclaimer_accepted';
  static const String keyAutoChangeSettings = 'auto_change_settings';

  // Auto Change Intervals (in minutes)
  static const List<int> autoChangeIntervals = [5, 15, 30, 60, 1440];

  // Max Cache Size (in MB)
  static const int maxCacheSize = 500;

  // Pagination
  static const int itemsPerPage = 20;
}
