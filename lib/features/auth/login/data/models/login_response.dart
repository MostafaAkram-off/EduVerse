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
}
