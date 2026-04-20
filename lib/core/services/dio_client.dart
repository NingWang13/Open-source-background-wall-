import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

/// HTTP Client Configuration
/// [Fix 10] 关闭 responseBody 避免图片 URL 泄露
/// [Fix 11] 超时从 30s 缩短为 10s/20s
class DioClient {
  DioClient._();

  static Dio? _unsplashDio;
  static Dio? _pexelsDio;

  /// Get Unsplash Dio instance
  static Dio get unsplashDio {
    _unsplashDio ??= _createDio(
      baseUrl: AppConstants.unsplashBaseUrl,
      apiKey: AppConstants.unsplashAccessKey,
      keyHeader: 'Authorization',
      keyPrefix: 'Client-ID ',
    );
    return _unsplashDio!;
  }

  /// Get Pexels Dio instance
  static Dio get pexelsDio {
    _pexelsDio ??= _createDio(
      baseUrl: AppConstants.pexelsBaseUrl,
      apiKey: AppConstants.pexelsApiKey,
      keyHeader: 'Authorization',
    );
    return _pexelsDio!;
  }

  static Dio _createDio({
    required String baseUrl,
    required String apiKey,
    required String keyHeader,
    String? keyPrefix,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),  // [Fix 11] 30s → 10s
        receiveTimeout: const Duration(seconds: 20),   // [Fix 11] 30s → 20s
        headers: {
          keyHeader: '$keyPrefix$apiKey',
          'Accept': 'application/json',
        },
      ),
    );

    // [Fix 10] 关闭 body 打印，保护图片 URL 隐私
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (o) {
            final msg = o.toString();
            debugPrint('[Dio] ${msg.length > 200 ? '${msg.substring(0, 200)}...' : msg}');
          },
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('[Dio] API Error: ${error.message}');
          debugPrint('[Dio] Status: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
