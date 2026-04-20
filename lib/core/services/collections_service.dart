import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/wallpaper.dart';

/// 收藏专辑/收藏夹服务
/// 用户可以创建多个收藏专辑来分类管理壁纸
/// [NEW] 新功能
class CollectionsService {
  static const String _keyCollections = 'collections';
  static final Map<String, Collection> _collections = {};
  static final _collectionsController = StreamController<Map<String, Collection>>.broadcast();

  static Stream<Map<String, Collection>> get stream => _collectionsController.stream;
  static Map<String, Collection> get collections => Map.unmodifiable(_collections);

  /// 获取所有专辑
  static List<Collection> get allCollections => _collections.values.toList();

  /// 获取默认收藏夹
  static Collection? get defaultCollection => _collections['default'];

  /// 获取指定专辑
  static Collection? get(String id) => _collections[id];

  /// 初始化
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCollections);

    _collections.clear();

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final list = jsonDecode(jsonString) as List;
        for (final item in list) {
          final collection = Collection.fromJson(item as Map<String, dynamic>);
          _collections[collection.id] = collection;
        }
      } catch (e) {
        debugPrint('Failed to load collections: $e');
        _createDefault();
      }
    }

    // 确保有默认收藏夹
    if (!_collections.containsKey('default')) {
      _createDefault();
    }

    _notify();
  }

  /// 创建默认收藏夹
  static void _createDefault() {
    _collections['default'] = Collection(
      id: 'default',
      name: '我的收藏',
      description: '默认收藏夹',
      iconCodePoint: Icons.favorite.codePoint,
      createdAt: DateTime.now(),
    );
  }

  /// 创建专辑
  static Future<Collection> createCollection({
    required String name,
    String? description,
    int iconCodePoint = 0, // 0 = use default
    List<String>? wallpaperIds,
  }) async {
    final id = 'col_${DateTime.now().millisecondsSinceEpoch}';
    final collection = Collection(
      id: id,
      name: name,
      description: description,
      iconCodePoint: iconCodePoint,
      wallpaperIds: wallpaperIds ?? [],
      createdAt: DateTime.now(),
    );

    _collections[id] = collection;
    await _save();
    _notify();
    return collection;
  }

  /// 重命名专辑
  static Future<void> renameCollection(String id, String newName) async {
    if (!_collections.containsKey(id)) return;
    _collections[id] = _collections[id]!.copyWith(name: newName);
    await _save();
    _notify();
  }

  /// 删除专辑（保留默认收藏夹）
  static Future<void> deleteCollection(String id) async {
    if (id == 'default') return; // 不能删除默认收藏夹
    _collections.remove(id);
    await _save();
    _notify();
  }

  /// 添加壁纸到专辑
  static Future<void> addToCollection(String collectionId, Wallpaper wallpaper) async {
    if (!_collections.containsKey(collectionId)) return;
    final collection = _collections[collectionId]!;
    if (collection.wallpaperIds.contains(wallpaper.id)) return;

    _collections[collectionId] = collection.copyWith(
      wallpaperIds: [...collection.wallpaperIds, wallpaper.id],
    );
    await _save();
    _notify();
  }

  /// 从专辑移除壁纸
  static Future<void> removeFromCollection(String collectionId, String wallpaperId) async {
    if (!_collections.containsKey(collectionId)) return;
    final collection = _collections[collectionId]!;

    _collections[collectionId] = collection.copyWith(
      wallpaperIds: collection.wallpaperIds.where((id) => id != wallpaperId).toList(),
    );
    await _save();
    _notify();
  }

  /// 获取专辑中的壁纸数量
  static int count(String collectionId) {
    return _collections[collectionId]?.wallpaperIds.length ?? 0;
  }

  /// 保存到本地
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _collections.values.map((c) => c.toJson()).toList();
    await prefs.setString(_keyCollections, jsonEncode(list));
  }

  static void _notify() {
    _collectionsController.add(Map.unmodifiable(_collections));
  }
}

/// 收藏专辑模型
class Collection {
  final String id;
  final String name;
  final String? description;
  final int iconCodePoint; // IconData.codePoint
  final List<String> wallpaperIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Collection({
    required this.id,
    required this.name,
    this.description,
    required this.iconCodePoint,
    this.wallpaperIds = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // ignore: non_const_argument_for_const_parameter (IconData API limitation in Flutter SDK)
  IconData get iconData => IconData(iconCodePoint);

  int get count => wallpaperIds.length;

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCodePoint,
    List<String>? wallpaperIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      wallpaperIds: wallpaperIds ?? this.wallpaperIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCodePoint': iconCodePoint,
      'wallpaperIds': wallpaperIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description']?.toString(),
      iconCodePoint: json['iconCodePoint'] ?? 58039,
      wallpaperIds: (json['wallpaperIds'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
