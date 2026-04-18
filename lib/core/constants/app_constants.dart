import 'package:flutter/material.dart';

/// App Constants
class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Wallhaven';
  static const String appVersion = '1.0.0';
  static const String appDescription = '免费跨平台壁纸应用';
  
  // API Keys (TODO: Replace with your own API keys)
  static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  static const String unsplashSecretKey = 'YOUR_UNSPLASH_SECRET_KEY';
  static const String pexelsApiKey = 'YOUR_PEXELS_API_KEY';
  
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
    '全部',
    '自然',
    '建筑',
    '科技',
    '动物',
    '人物',
    '抽象',
    '游戏',
    '电影',
    '动漫',
  ];
  
  // Colors for filtering (non-const because Colors.xxx is not const-assignable in all contexts)
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
