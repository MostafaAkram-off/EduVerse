import 'package:edu_verse/features/auth/shared/user_data.dart';
import 'package:edu_verse/features/auth/shared/user_role.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess({required this.user, required this.role});
  final UserData user;
  final UserRole role;
}

class LoginError extends LoginState {
  const LoginError(this.message);
  final String message;
}
