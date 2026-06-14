import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/auth/shared/auth_session.dart';

class DioModule {
  DioModule._();

  static Dio create({List<Interceptor>? extraInterceptors}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          Headers.acceptHeader: 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      // Attach Bearer token from AuthSession on every request
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra['skipAuth'] != true) {
            final token = AuthSession.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          // Let multipart/form-data set its own Content-Type
          if (options.data is! FormData) {
            options.headers[Headers.contentTypeHeader] = 'application/json';
          }
          handler.next(options);
        },
      ),
      LogInterceptor(requestBody: true, responseBody: true, error: true),
      if (extraInterceptors != null) ...extraInterceptors,
    ]);

    return dio;
  }
}
