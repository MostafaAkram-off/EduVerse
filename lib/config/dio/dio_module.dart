import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/preferences/app_preferences.dart';
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
      // Attach Bearer token + handle 401 by clearing session
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra['skipAuth'] != true) {
            final token = AuthSession.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          if (options.data is! FormData) {
            options.headers[Headers.contentTypeHeader] = 'application/json';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired — clear session so the app redirects to login
            AuthSession.clear();
            await AppPreferences.instance.clearSession();
          }
          handler.next(error);
        },
      ),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true, error: true),
      if (extraInterceptors != null) ...extraInterceptors,
    ]);

    return dio;
  }
}
