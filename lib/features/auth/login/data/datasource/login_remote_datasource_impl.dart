import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';
import 'package:edu_verse/core/utils/jwt_decoder.dart';
import 'package:edu_verse/features/auth/login/data/datasource/login_remote_datasource.dart';
import 'package:edu_verse/features/auth/login/data/models/login_request.dart';
import 'package:edu_verse/features/auth/login/data/models/login_response.dart';
import 'package:edu_verse/features/auth/shared/user_data.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

class LoginRemoteDatasourceImpl implements LoginRemoteDatasource {
  LoginRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final data = response.data ?? {};
    if (data['succeed'] != true) {
      throw Exception(data['message'] ?? 'Login failed');
    }

    final token = data['token'] as String? ?? '';
    final refreshToken = data['refreshToken'] as String?;
    final claims = JwtDecoder.decode(token);

    final user = UserData(
      id:        JwtDecoder.getUserId(claims),
      name:      JwtDecoder.getUserName(claims),
      fullName:  JwtDecoder.getFullName(claims),
      email:     JwtDecoder.getEmail(claims),
      role:      UserRole.fromString(JwtDecoder.getRole(claims)),
      isVerified: true,
    );

    return LoginResponse(token: token, refreshToken: refreshToken, user: user);
  }
}
