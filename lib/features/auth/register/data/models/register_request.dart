import 'package:edu_verse/features/auth/shared/user_role.dart';

class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String birth;           // "yyyy-MM-dd"
  final String password;
  final String confirmPassword;
  final UserRole role;
  final String confirmationCode; // OTP — filled on verify screen

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.birth,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.confirmationCode = '',
  });

  RegisterRequest copyWith({String? confirmationCode}) => RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        birth: birth,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        confirmationCode: confirmationCode ?? this.confirmationCode,
      );

  Map<String, dynamic> toJson() => {
        'userName':        name,
        'FullName':        name,
        'email':           email,
        'phoneNumber':     phone,
        'Birth':           birth,
        'password':        password,
        'confirmPassword': confirmPassword,
        'role':            role.value,
        'ConfirmationCode': confirmationCode,
      };
}
