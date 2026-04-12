import 'package:edu_verse/features/auth/shared/user_data.dart';

class LoginResponse {
  final String token;
  final String? refreshToken;
  final UserData user;

  const LoginResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      user: UserData.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
