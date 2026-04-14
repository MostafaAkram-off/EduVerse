import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
// TODO: re-enable navigation imports when auth screens are merged into dev
// import 'package:edu_verse/core/navigation/app_routes.dart';
// import 'package:edu_verse/core/navigation/app_router.dart';

class DioModule {
  DioModule._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: _refreshTokenKey);

            if (refreshToken != null) {
              try {
                // Attempt token refresh
                final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
                final response = await refreshDio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refreshToken': refreshToken},
                );
                final newToken = response.data['token'] as String?;
                final newRefreshToken = response.data['refreshToken'] as String?;

                if (newToken != null) {
                  await _storage.write(key: _tokenKey, value: newToken);
                  if (newRefreshToken != null) {
                    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
                  }
                  // Retry the original request with the new token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                // Refresh failed — fall through to force logout
              }
            }

            // No refresh token or refresh failed — clear storage
            // TODO: navigate to login once auth screens are merged into dev
            await _clearSession();
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Saves tokens after a successful login/register.
  static Future<void> saveTokens({
    required String token,
    String? refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Reads the current access token.
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Clears all stored auth tokens (call on logout).
  static Future<void> clearSession() => _clearSession();

  static Future<void> _clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
