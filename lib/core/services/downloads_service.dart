import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 下载记录
class DownloadRecord {
  final String id;
  final String wallpaperId;
  final String filePath;
  final DateTime downloadTime;
  final String resolution;
  final int fileSize;

  DownloadRecord({
    required this.id,
    required this.wallpaperId,
    required this.filePath,
    required this.downloadTime,
    required this.resolution,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'wallpaperId': wallpaperId,
    'filePath': filePath,
    'downloadTime': downloadTime.toIso8601String(),
    'resolution': resolution,
    'fileSize': fileSize,
  };

  factory DownloadRecord.fromJson(Map<String, dynamic> json) => DownloadRecord(
    id: json['id'] ?? '',
    wallpaperId: json['wallpaperId'] ?? '',
    filePath: json['filePath'] ?? '',
    downloadTime: DateTime.tryParse(json['downloadTime'] ?? '') ?? DateTime.now(),
    resolution: json['resolution'] ?? '',
    fileSize: json['fileSize'] ?? 0,
  );

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 下载服务
class DownloadsService {
  static const String _keyDownloads = 'downloads';
  static final List<DownloadRecord> _downloads = [];
  static final _downloadsController = StreamController<List<DownloadRecord>>.broadcast();

  static Stream<List<DownloadRecord>> get downloadsStream => _downloadsController.stream;
  static List<DownloadRecord> get downloads => List.unmodifiable(_downloads);

  /// 初始化
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyDownloads) ?? [];
    _downloads.clear();
    for (final _ in jsonList) {
      try {
        // TODO: 后续实现完整的 JSON 反序列化
        _downloads.add(DownloadRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          wallpaperId: '',
          filePath: '',
          downloadTime: DateTime.now(),
          resolution: '',
          fileSize: 0,
        ));
      } catch (e) {
        debugPrint('Failed to parse download record: $e');
      }
    }
    _downloadsController.add(List.unmodifiable(_downloads));
  }

  /// 添加下载记录
  static Future<void> addDownload(DownloadRecord record) async {
    _downloads.insert(0, record);
    await _saveDownloads();
    _downloadsController.add(List.unmodifiable(_downloads));
  }

  /// 删除下载记录
  static Future<void> removeDownload(String id) async {
    _downloads.removeWhere((d) => d.id == id);
    await _saveDownloads();
    _downloadsController.add(List.unmodifiable(_downloads));
  }

  /// 清空下载记录
  static Future<void> clearDownloads() async {
    _downloads.clear();
    await _saveDownloads();
    _downloadsController.add(List.unmodifiable(_downloads));
  }

  /// 保存到本地
  static Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    // 简化存储
    await prefs.setStringList(_keyDownloads, []);
  }

  /// 获取下载目录
  static Future<String> getDownloadDir() async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/wallhaven');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }
}
