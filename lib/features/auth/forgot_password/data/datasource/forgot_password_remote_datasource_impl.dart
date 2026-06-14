import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/auth/forgot_password/data/datasource/forgot_password_remote_datasource.dart';

class ForgotPasswordRemoteDatasourceImpl
    implements ForgotPasswordRemoteDatasource {
  ForgotPasswordRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> sendResetCode(String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    final data = response.data ?? {};
    if (data['succeed'] == false) {
      throw Exception(data['message'] ?? 'Failed to send reset code');
    }
  }

  @override
  Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.verifyCode,
      data: {'email': email, 'code': code},
    );
    final data = response.data ?? {};
    if (data['succeed'] == false) {
      throw Exception(data['message'] ?? 'Invalid code');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
    final data = response.data ?? {};
    if (data['succeed'] == false) {
      throw Exception(data['message'] ?? 'Failed to reset password');
    }
  }
}
