/// Wallpaper Model - 简化版，不需要代码生成
class Wallpaper {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String author;
  final String authorUrl;
  final int width;
  final int height;
  final String? description;
  final String? color;
  final List<String> tags;
  final int likes;
  final int downloads;
  final DateTime? createdAt;
  final String? source; // 'unsplash', 'pexels', 'local'

  const Wallpaper({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.author,
    required this.authorUrl,
    required this.width,
    required this.height,
    this.description,
    this.color,
    this.tags = const [],
    this.likes = 0,
    this.downloads = 0,
    this.createdAt,
    this.source,
  });

  /// 从 JSON 创建
  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? 
                    json['thumbnail_url']?.toString() ?? '',
      author: json['author']?.toString() ?? 
              json['user']?['name']?.toString() ?? '',
      authorUrl: json['authorUrl']?.toString() ?? 
                 json['user']?['links']?['html']?.toString() ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      description: json['description']?.toString() ?? 
                   json['alt_description']?.toString(),
      color: json['color']?.toString() ?? 
             json['avg_color']?.toString(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      source: json['source']?.toString(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'authorUrl': authorUrl,
      'width': width,
      'height': height,
      'description': description,
      'color': color,
      'tags': tags,
      'likes': likes,
      'downloads': downloads,
      'createdAt': createdAt?.toIso8601String(),
      'source': source,
    };
  }

  /// 获取宽高比
  double get aspectRatio => width / height;

  /// 获取分辨率描述
  String get resolutionText {
    if (width >= 3840 || height >= 2160) return '4K';
    if (width >= 2560 || height >= 1440) return '2K';
    if (width >= 1920 || height >= 1080) return '1080p';
    return '${width}x$height';
  }

  @override
  String toString() => 'Wallpaper(id: $id, author: $author)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Wallpaper Resolution Enum
enum WallpaperResolution {
  original('原画质'),
  k2('2K'),
  k4('4K');

  final String label;
  const WallpaperResolution(this.label);
}

/// Wallpaper Category
enum WallpaperCategory {
  all('全部'),
  nature('自然'),
  architecture('建筑'),
  technology('科技'),
  animals('动物'),
  people('人物'),
  abstract('抽象'),
  gaming('游戏'),
  movies('电影'),
  anime('动漫');

  final String label;
  const WallpaperCategory(this.label);
}
