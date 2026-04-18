import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Wallpaper Service - 跨平台壁纸设置服务
/// 支持 Android, iOS, Windows, macOS, Linux, Web
class WallpaperService {
  // 统一的方法通道
  static const MethodChannel _channel = MethodChannel('com.wallhaven.wallpaper_app/wallpaper');

  /// 设置壁纸
  /// 
  /// [filePath] - 本地文件路径
  /// [location] - 壁纸位置: 0=全部, 1=主屏, 2=锁屏
  static Future<bool> setWallpaper(String filePath, {int location = 0}) async {
    try {
      if (kIsWeb) {
        // Web 平台 - 只能提示用户手动设置
        throw UnsupportedError('Web platform cannot set system wallpaper');
      }
      
      final result = await _channel.invokeMethod('setWallpaper', {
        'filePath': filePath,
        'location': location,
      });
      
      return result == true || result == 'Wallpaper set successfully';
    } on PlatformException catch (e) {
      throw Exception('Failed to set wallpaper: ${e.message}');
    }
  }

  /// 从 URL 下载并设置壁纸 (需要先下载)
  static Future<void> setWallpaperFromUrl(String url, {int location = 0}) async {
    // Web 平台不支持
    if (kIsWeb) {
      throw UnsupportedError('Web platform cannot set system wallpaper');
    }
    
    // 使用 download_service 先下载，然后设置
    // 详见 DownloadService.downloadAndSet
    throw UnimplementedError('Use DownloadService.downloadAndSet instead');
  }

  /// 获取当前壁纸路径 (仅部分平台支持)
  static Future<String?> getCurrentWallpaper() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<String>('getWallpaper');
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 检查平台是否支持设置壁纸
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || 
           Platform.isIOS || 
           Platform.isWindows || 
           Platform.isMacOS || 
           Platform.isLinux;
  }

  /// 获取平台名称
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}

/// 壁纸位置枚举
enum WallpaperLocation {
  both(0, '全部'),
  home(1, '主屏幕'),
  lock(2, '锁屏');

  const WallpaperLocation(this.value, this.label);
  final int value;
  final String label;
}

/// 壁纸屏幕枚举 (兼容旧代码)
enum WallpaperScreen {
  home,
  lock,
  both;
  
  int get value => index;
}