import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<Response> login(Map<String, dynamic> body) =>
      _dio.post('auth/login', data: body);

  Future<Response> register(Map<String, dynamic> body) =>
      _dio.post('auth/register', data: body);

  Future<Response> verifyEmail(Map<String, dynamic> body) =>
      _dio.post('auth/verify-email', data: body);

  Future<Response> resendVerificationCode(Map<String, dynamic> body) =>
      _dio.post('auth/resend-verification', data: body);

  Future<Response> forgotPassword(Map<String, dynamic> body) =>
      _dio.post('auth/forgot-password', data: body);

  Future<Response> verifyOtp(Map<String, dynamic> body) =>
      _dio.post('auth/verify-otp', data: body);

  Future<Response> resetPassword(Map<String, dynamic> body) =>
      _dio.post('auth/reset-password', data: body);

  Future<Response> logout() => _dio.post('auth/logout');

  Future<Response> refreshToken(Map<String, dynamic> body) =>
      _dio.post('auth/refresh-token', data: body);
}
