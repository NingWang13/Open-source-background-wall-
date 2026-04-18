import 'package:dio/dio.dart';
import '../models/wallpaper.dart';

/// Pexels API Service
class PexelsApi {
  static const String _baseUrl = 'https://api.pexels.com/v1';
  static String? _apiKey;
  static final Dio _dio = Dio();

  /// 设置 API Key
  static void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _dio.options.headers['Authorization'] = apiKey;
  }

  /// 获取精选壁纸
  static Future<List<Wallpaper>> getCuratedPhotos({int page = 1, int perPage = 20}) async {
    if (_apiKey == null) {
      return _getMockWallpapers('pexels');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/curated',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final photos = response.data['photos'] as List;
      return photos.map((photo) => _parsePexelsPhoto(photo)).toList();
    } catch (e) {
      return _getMockWallpapers('pexels');
    }
  }

  /// 搜索壁纸
  static Future<List<Wallpaper>> searchPhotos(String query, {int page = 1, int perPage = 20}) async {
    if (_apiKey == null) {
      return _getMockWallpapers('pexels');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );

      final photos = response.data['photos'] as List;
      return photos.map((photo) => _parsePexelsPhoto(photo)).toList();
    } catch (e) {
      return _getMockWallpapers('pexels');
    }
  }

  /// 获取壁纸详情
  static Future<Wallpaper?> getPhoto(String id) async {
    if (_apiKey == null) return null;

    try {
      final response = await _dio.get('$_baseUrl/photos/$id');
      return _parsePexelsPhoto(response.data);
    } catch (e) {
      return null;
    }
  }

  /// 解析 Pexels 图片数据
  static Wallpaper _parsePexelsPhoto(Map<String, dynamic> photo) {
    return Wallpaper(
      id: photo['id']?.toString() ?? '',
      url: photo['src']?['original']?.toString() ?? 
           photo['src']?['large']?.toString() ?? '',
      thumbnailUrl: photo['src']?['medium']?.toString() ?? 
                    photo['src']?['small']?.toString() ?? '',
      author: photo['photographer']?.toString() ?? '',
      authorUrl: photo['photographer_url']?.toString() ?? '',
      width: photo['width'] as int? ?? 0,
      height: photo['height'] as int? ?? 0,
      description: photo['alt']?.toString(),
      color: photo['avg_color']?.toString(),
      likes: 0,
      downloads: 0,
      source: 'pexels',
    );
  }

  /// 模拟数据（无 API Key 时使用）
  static List<Wallpaper> _getMockWallpapers(String source) {
    return List.generate(10, (i) => Wallpaper(
      id: '${source}_$i',
      url: 'https://picsum.photos/1920/1080?random=${i + 100}',
      thumbnailUrl: 'https://picsum.photos/400/300?random=${i + 100}',
      author: 'Photographer $i',
      authorUrl: 'https://pexels.com',
      width: 1920,
      height: 1080,
      description: 'Curated wallpaper $i',
      source: source,
    ));
  }
}
