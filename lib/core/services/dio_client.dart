import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

/// HTTP Client Configuration
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
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          keyHeader: '$keyPrefix$apiKey',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }

    // Add error interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          debugPrint('Status Code: ${error.response?.statusCode}');
          debugPrint('Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}