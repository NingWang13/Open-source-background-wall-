import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 下载服务
class DownloadService {
  DownloadService._();

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

    await Dio().download(
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
