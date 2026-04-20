import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 下载记录模型
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

/// 下载记录服务
/// [NEW] 完整实现 JSON 持久化
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

    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _downloads.add(DownloadRecord.fromJson(map));
      } catch (e) {
        debugPrint('Failed to parse download record: $e');
      }
    }

    _downloadsController.add(List.unmodifiable(_downloads));
  }

  /// 添加下载记录
  static Future<void> addDownload(DownloadRecord record) async {
    _downloads.insert(0, record); // 最新在前
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
  /// [Fix] 使用 jsonEncode 正确序列化
  static Future<void> _saveDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _downloads.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_keyDownloads, jsonList);
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
