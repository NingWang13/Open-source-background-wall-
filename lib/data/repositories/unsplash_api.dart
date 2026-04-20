import 'package:dio/dio.dart';
import '../models/wallpaper.dart';

/// Unsplash API Service
/// [Fix Bug 2] 模拟数据 now respects perPage parameter
class UnsplashApi {
  static const String _baseUrl = 'https://api.unsplash.com';
  static String? _apiKey;
  static final Dio _dio = Dio();

  /// 设置 API Key
  static void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _dio.options.headers['Authorization'] = 'Client-ID $apiKey';
  }

  /// 获取随机壁纸
  /// [Fix Bug 2] perPage 参数正确传递给模拟数据
  static Future<List<Wallpaper>> getRandomPhotos({int page = 1, int perPage = 20}) async {
    if (_apiKey == null) {
      return _getMockWallpapers('unsplash', perPage: perPage);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/photos/random',
        queryParameters: {
          'count': perPage,
          'page': page,
        },
      );

      final photos = response.data as List;
      return photos.map((photo) => _parseUnsplashPhoto(photo)).toList();
    } catch (e) {
      return _getMockWallpapers('unsplash', perPage: perPage);
    }
  }

  /// 搜索壁纸
  /// [Fix Bug 2] perPage 参数正确传递给模拟数据
  static Future<List<Wallpaper>> searchPhotos(String query, {int page = 1, int perPage = 20}) async {
    if (_apiKey == null) {
      return _getMockWallpapers('unsplash', perPage: perPage);
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/search/photos',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );

      final results = response.data['results'] as List;
      return results.map((photo) => _parseUnsplashPhoto(photo)).toList();
    } catch (e) {
      return _getMockWallpapers('unsplash', perPage: perPage);
    }
  }

  /// 获取壁纸详情
  static Future<Wallpaper?> getPhoto(String id) async {
    if (_apiKey == null) return null;

    try {
      final response = await _dio.get('$_baseUrl/photos/$id');
      return _parseUnsplashPhoto(response.data);
    } catch (e) {
      return null;
    }
  }

  /// 解析 Unsplash 图片数据
  static Wallpaper _parseUnsplashPhoto(Map<String, dynamic> photo) {
    return Wallpaper(
      id: photo['id']?.toString() ?? '',
      url: photo['urls']?['raw']?.toString() ??
           photo['urls']?['full']?.toString() ?? '',
      thumbnailUrl: photo['urls']?['small']?.toString() ??
                    photo['urls']?['thumb']?.toString() ?? '',
      author: photo['user']?['name']?.toString() ?? '',
      authorUrl: photo['user']?['links']?['html']?.toString() ?? '',
      width: photo['width'] as int? ?? 0,
      height: photo['height'] as int? ?? 0,
      description: photo['description']?.toString() ??
                   photo['alt_description']?.toString(),
      color: photo['color']?.toString(),
      likes: photo['likes'] as int? ?? 0,
      downloads: photo['downloads'] as int? ?? 0,
      createdAt: photo['created_at'] != null
          ? DateTime.tryParse(photo['created_at'].toString())
          : null,
      source: 'unsplash',
    );
  }

  /// 模拟数据（无 API Key 时使用）
  /// [Fix Bug 2] 根据 perPage 参数生成对应数量的模拟数据
  static List<Wallpaper> _getMockWallpapers(String source, {int perPage = 20}) {
    return List.generate(perPage, (i) => Wallpaper(
      id: '${source}_${pageSeed(source, i)}',
      url: 'https://picsum.photos/1920/1080?random=${pageSeed(source, i)}',
      thumbnailUrl: 'https://picsum.photos/400/300?random=${pageSeed(source, i)}',
      author: 'Unsplash Photographer $i',
      authorUrl: 'https://unsplash.com',
      width: 1920,
      height: 1080,
      description: 'Beautiful wallpaper $i',
      source: source,
    ));
  }

  /// 生成确定性随机种子（避免每次生成不同图片 URL）
  static int pageSeed(String source, int index) {
    return (source.hashCode + index) % 500 + (source == 'unsplash' ? 0 : 100);
  }
}
