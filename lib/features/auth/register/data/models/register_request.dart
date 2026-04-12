import 'package:edu_verse/features/auth/shared/user_role.dart';

class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final UserRole role;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'confirm_password': confirmPassword,
        'role': role.value,
      };
}
