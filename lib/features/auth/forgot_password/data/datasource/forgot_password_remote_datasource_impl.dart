import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource.dart';

class ForgotPasswordRemoteDatasourceImpl
    implements ForgotPasswordRemoteDatasource {
  ForgotPasswordRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> sendResetCode(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      final data = response.data ?? {};
      if (data['succeed'] == false) {
        throw Exception(data['message'] ?? 'Failed to send reset code');
      }
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e) ?? 'This feature is not available yet.',
      );
    }
  }

  @override
  Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyCode,
        data: {'email': email, 'code': code},
      );
      final data = response.data ?? {};
      if (data['succeed'] == false) {
        throw Exception(data['message'] ?? 'Invalid code');
      }
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Invalid or expired code.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      final data = response.data ?? {};
      if (data['succeed'] == false) {
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
    } on DioException catch (e) {
      throw Exception(_extractMessage(e) ?? 'Failed to reset password.');
    }
  }

  String? _extractMessage(DioException e) {
    final body = e.response?.data;
    if (body is Map) {
      return (body['message'] ?? body['Message'] ?? body['error'])?.toString();
    }
    if (body is String && body.isNotEmpty) return body;
    return null;
  }
}
