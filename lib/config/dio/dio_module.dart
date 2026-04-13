import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class DioModule {
  DioModule._();

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
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: inject Bearer token from FlutterSecureStorage
        return handler.next(options);
      },
      onError: (error, handler) async {
        // TODO: handle 401 → refresh token or redirect to login
        return handler.next(error);
      },
    ));

    return dio;
  }
}
