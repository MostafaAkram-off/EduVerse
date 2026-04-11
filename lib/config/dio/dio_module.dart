import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

/// Creates a configured [Dio] instance. Register once in DI when you wire GetIt.
class DioModule {
  DioModule._();

  static Dio create({
    String? baseUrl,
    String? accessToken,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          Headers.acceptHeader: 'application/json',
          Headers.contentTypeHeader: 'application/json',
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
      if (extraInterceptors != null) ...extraInterceptors,
    ]);

    return dio;
  }
}
