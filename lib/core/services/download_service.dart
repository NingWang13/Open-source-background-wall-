import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 下载服务
/// [Fix 8] Dio 单例复用，不再每次 new 一个实例
class DownloadService {
  DownloadService._();

  static Dio? _dio;

  /// 复用单个 Dio 实例，避免频繁创建导致的 GC 压力
  static Dio get _dioInstance {
    _dio ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    return _dio!;
  }

  /// 下载文件
  static Future<String> downloadFile(
    String url, {
    String? fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Web platform does not support file download to local');
    }

    final dir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${dir.path}/wallhaven');
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final name = fileName ?? 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savePath = path.join(saveDir.path, name);

    // [Fix 8] 使用单例实例而非每次 new Dio()
    await _dioInstance.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
    );

    return savePath;
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
