import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<Response> login(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.login, data: body);
  }

  Future<Response> register(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.register, data: body);
  }

  Future<Response> verifyEmail(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.verifyEmail, data: body);
  }

  Future<Response> resendVerificationCode(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.resendVerification, data: body);
  }

  Future<Response> forgotPassword(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.forgotPassword, data: body);
  }

  Future<Response> verifyOtp(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.verifyOtp, data: body);
  }

  Future<Response> resetPassword(Map<String, dynamic> body) async {
    return _dio.post(ApiEndpoints.resetPassword, data: body);
  }
}