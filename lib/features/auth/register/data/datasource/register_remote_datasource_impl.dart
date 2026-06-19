import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/features/auth/register/data/datasource/register_remote_datasource.dart';
import 'package:edu_verse/features/auth/register/data/models/register_request.dart';
import 'package:edu_verse/features/auth/register/data/models/register_response.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

class RegisterRemoteDatasourceImpl implements RegisterRemoteDatasource {
  RegisterRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  /// Step 1 — only sends the OTP, does NOT call Register yet.
  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      await _dio.post<void>(ApiEndpoints.sendConfirmationEmail(request.email));
    } on DioException catch (e) {
      final msg = _extractMessage(e) ?? 'Failed to send verification code';
      throw Exception(msg);
    }
    return RegisterResponse(
      message: 'Verification code sent to ${request.email}',
      email: request.email,
    );
  }

  /// Step 2 — submits the full form + OTP to create the account.
  @override
  Future<void> verifyEmail({
    required RegisterRequest request,
    required String code,
  }) async {
    final full = request.copyWith(confirmationCode: code);
    final formData = FormData.fromMap({
      'UserName':         full.name,
      'FullName':         full.name,
      'Email':            full.email,
      'phoneNumber':      full.phone,
      'Birth':            full.birth,
      'Password':         full.password,
      'confirmPassword':  full.confirmPassword,
      'role': full.role == UserRole.instructor ? 'Instructor' : 'Student',
      'ConfirmationCode': full.confirmationCode,
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: formData,
      );
      final data = response.data ?? {};
      if (data['succeed'] == false) {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final msg = _extractMessage(e)
          ?? 'Invalid or expired code. Please request a new one.';
      throw Exception(msg);
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    try {
      await _dio.post<void>(ApiEndpoints.sendConfirmationEmail(email));
    } on DioException catch (e) {
      final msg = _extractMessage(e) ?? 'Failed to resend code';
      throw Exception(msg);
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
