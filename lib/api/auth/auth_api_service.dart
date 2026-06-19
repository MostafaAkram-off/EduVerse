import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> login(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.login, data: body);

  Future<Response<dynamic>> register(FormData formData) =>
      _dio.post(ApiEndpoints.register, data: formData);

  Future<Response<dynamic>> confirmEmail(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.confirmEmail, data: body);

  Future<Response<dynamic>> sendConfirmationEmail(String email) =>
      _dio.post(ApiEndpoints.sendConfirmationEmail(email));

  Future<Response<dynamic>> forgotPassword(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.forgotPassword, data: body);

  Future<Response<dynamic>> verifyCode(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.verifyCode, data: body);

  Future<Response<dynamic>> resetPassword(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.resetPassword, data: body);

  Future<Response<dynamic>> getProfile() =>
      _dio.get(ApiEndpoints.getProfile);

  Future<Response<dynamic>> reviveToken(String token) =>
      _dio.post(ApiEndpoints.reviveToken, data: token);
}
