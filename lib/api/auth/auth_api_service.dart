import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

/// Remote auth calls. Map responses to models in your datasource layer.
class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> login(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.login, data: body);

  Future<Response<dynamic>> register(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.register, data: body);

  Future<Response<dynamic>> logout() => _dio.post(ApiEndpoints.logout);

  Future<Response<dynamic>> refreshToken(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.refreshToken, data: body);

  Future<Response<dynamic>> forgotPassword(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.forgotPassword, data: body);

  Future<Response<dynamic>> verifyOtp(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.verifyOtp, data: body);

  Future<Response<dynamic>> resetPassword(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.resetPassword, data: body);
}
